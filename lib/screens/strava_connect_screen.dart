import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../l10n/app_localizations.dart';
import '../state/app_store.dart';
import '../strava/open_browser.dart';
import '../strava/strava_app_auth.dart';
import '../strava/strava_config.dart';
import '../strava/strava_oauth.dart';
import '../widgets/app_text_field.dart';

class StravaConnectScreen extends StatefulWidget {
  const StravaConnectScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<StravaConnectScreen> createState() => _StravaConnectScreenState();
}

class _StravaConnectScreenState extends State<StravaConnectScreen> {
  late final TextEditingController _clientId;
  late final TextEditingController _clientSecret;
  final _http = http.Client();
  StravaLoopbackListener? _listener;
  String? _state;
  Uri? _authorizeUrl;
  String? _message;
  bool _busy = false;
  bool _waitingBrowser = false;
  bool _browserFailedToOpen = false;

  @override
  void initState() {
    super.initState();
    final settings = widget.store.settings;
    _clientId = TextEditingController(text: settings.stravaClientId ?? '');
    _clientSecret = TextEditingController(text: settings.stravaClientSecret ?? '');
    _fillFromFile();
  }

  Future<void> _fillFromFile() async {
    if (_clientId.text.isNotEmpty && _clientSecret.text.isNotEmpty) {
      return;
    }
    final loaded = await resolveStravaCredentials(
      storedClientId: widget.store.settings.stravaClientId,
      storedClientSecret: widget.store.settings.stravaClientSecret,
    );
    if (!mounted || loaded == null) {
      return;
    }
    setState(() {
      if (_clientId.text.isEmpty) {
        _clientId.text = loaded.clientId;
      }
      if (_clientSecret.text.isEmpty) {
        _clientSecret.text = loaded.clientSecret;
      }
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    _http.close();
    _clientId.dispose();
    _clientSecret.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final connected = widget.store.settings.stravaConnected;
        final athlete = widget.store.settings.stravaAthleteName;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.stravaConnect)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(
                connected ? l10n.connected : l10n.notConnected,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (athlete != null && athlete.isNotEmpty)
                Text(athlete, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Text(l10n.clientId, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              AppTextField(
                controller: _clientId,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.clientIdHint,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.clientSecret,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              AppTextField(
                controller: _clientSecret,
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.clientSecretHint,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _connect,
                child: Text(connected ? l10n.connectAgain : l10n.connect),
              ),
              if (_waitingBrowser) ...[
                const SizedBox(height: 12),
                Text(
                  Platform.isIOS
                      ? l10n.waitingBrowserIos
                      : stravaUsesAppCallback
                      ? l10n.waitingBrowserMobile
                      : l10n.waitingBrowser,
                ),
                if (!stravaUsesAppCallback &&
                    _browserFailedToOpen &&
                    _authorizeUrl != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.browserDidNotOpen,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _authorizeUrl.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: _authorizeUrl.toString()),
                      );
                      if (mounted) {
                        setState(
                          () => _message =
                              AppLocalizations.of(context).copiedAuthorizeUrl,
                        );
                      }
                    },
                    child: Text(l10n.copyAuthorizeUrl),
                  ),
                ],
              ],
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy || !connected ? null : _disconnect,
                child: Text(l10n.disconnect),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(_message!),
              ],
              const SizedBox(height: 24),
              Text(l10n.howToConnect, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                l10n.connectStep1,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SelectableText('https://www.strava.com/settings/api'),
              Text(
                l10n.stravaPaidApi,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.connectStep2,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.noAccessToken,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.connectStep3,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                Platform.isIOS ? l10n.connectStep3HelpIos : l10n.connectStep3Help,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (!Platform.isIOS) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.connectStep4,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.connectStep4Help,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _connect() async {
    final l10n = AppLocalizations.of(context);
    final clientId = _clientId.text.trim();
    final clientSecret = _clientSecret.text.trim();
    if (clientId.isEmpty || clientSecret.isEmpty) {
      setState(() => _message = l10n.enterClientIdSecret);
      return;
    }
    setState(() {
      _busy = true;
      _message = Platform.isIOS
          ? l10n.waitingBrowserIos
          : stravaUsesAppCallback
          ? l10n.waitingBrowserMobile
          : l10n.waitingForChrome;
      _waitingBrowser = true;
      _browserFailedToOpen = false;
    });
    await widget.store.saveStravaCredentials(
      clientId: clientId,
      clientSecret: clientSecret,
    );
    _state = newOAuthState();
    final mobile = stravaUsesAppCallback;
    final url = stravaAuthorizeUrl(
      clientId: clientId,
      state: _state!,
      mobile: mobile,
    );
    _authorizeUrl = url;
    if (mobile) {
      try {
        final redirected = await authenticateStravaInAppBrowser(url);
        final code = extractAuthorizationCode(
          redirected,
          expectedState: _state!,
        );
        await _finishWithCode(code, clientId, clientSecret);
      } on StravaAuthException catch (e) {
        if (!mounted) {
          return;
        }
        setState(() {
          _busy = false;
          _waitingBrowser = false;
          _message = e.message;
        });
      } catch (e) {
        if (!mounted) {
          return;
        }
        setState(() {
          _busy = false;
          _waitingBrowser = false;
          _message = '$e';
        });
      }
      return;
    }
    _listener = StravaLoopbackListener();
    try {
      await _listener!.start();
    } on SocketException {
      setState(() {
        _busy = false;
        _waitingBrowser = false;
        _message = l10n.portBusy(stravaListenPort);
      });
      return;
    }
    final opened = await openInBrowser(url);
    if (mounted) {
      setState(() {
        _browserFailedToOpen = !opened;
        _message = opened ? l10n.closeChromeSuccess : l10n.browserDidNotOpen;
      });
    }
    try {
      final redirected = await _listener!.waitForRedirect();
      final code = extractAuthorizationCode(redirected, expectedState: _state!);
      await _finishWithCode(code, clientId, clientSecret);
    } on StravaAuthException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _message = e.message;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _message = '$e';
      });
    }
  }

  Future<void> _finishWithCode(
    String code,
    String clientId,
    String clientSecret,
  ) async {
    final result = await exchangeAuthorizationCode(
      client: _http,
      clientId: clientId,
      clientSecret: clientSecret,
      code: code,
    );
    await widget.store.saveStravaAuth(result);
    await _listener?.cancel();
    _listener = null;
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _waitingBrowser = false;
      _browserFailedToOpen = false;
      _message = AppLocalizations.of(context).tokenSaved(result.athleteName);
    });
  }

  Future<void> _disconnect() async {
    setState(() => _busy = true);
    final token = widget.store.settings.stravaAccessToken;
    if (token != null) {
      try {
        await deauthorizeStrava(client: _http, accessToken: token);
      } catch (_) {}
    }
    await widget.store.disconnectStrava();
    await _listener?.cancel();
    _listener = null;
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _waitingBrowser = false;
      _browserFailedToOpen = false;
      _message = AppLocalizations.of(context).disconnected;
    });
  }
}

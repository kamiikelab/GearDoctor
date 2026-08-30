import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../state/app_store.dart';
import '../strava/open_browser.dart';
import '../strava/strava_config.dart';
import '../strava/strava_oauth.dart';

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
        final connected = widget.store.settings.stravaConnected;
        final athlete = widget.store.settings.stravaAthleteName;
        return Scaffold(
          appBar: AppBar(title: const Text('Strava 連携')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                connected ? '連携済み' : '未連携',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (athlete != null && athlete.isNotEmpty)
                Text(athlete, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Text('Client ID', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              TextField(
                controller: _clientId,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Strava のアプリ登録で発行される番号',
                ),
              ),
              const SizedBox(height: 12),
              Text('Client Secret', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              TextField(
                controller: _clientSecret,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Strava のアプリ登録で Show すると出る値',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _connect,
                child: Text(connected ? '再連携' : '連携する'),
              ),
              if (_waitingBrowser) ...[
                const SizedBox(height: 12),
                const Text(
                  'Chrome に案内が出たら、その画面を必ず閉じてください。'
                  '閉じると、上の連携ボタンが再び緑になります。'
                  'アプリが手前に切り替わることはありません。',
                ),
                if (_browserFailedToOpen && _authorizeUrl != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Chrome が自動では開きませんでした。次の URL をコピーして Chrome で開いてください。',
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
                          () => _message = '許可用の URL をコピーしました。Chrome のアドレス欄に貼って開いてください。',
                        );
                      }
                    },
                    child: const Text('許可用 URL をコピー'),
                  ),
                ],
              ],
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy || !connected ? null : _disconnect,
                child: const Text('連携を解除'),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(_message!),
              ],
              const SizedBox(height: 24),
              Text('連携方法', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '1. Strava の API 設定でアプリを作る',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SelectableText('https://www.strava.com/settings/api'),
              Text(
                'Authorization Callback Domain は 127.0.0.1。'
                'http もポートもパスも付けない。この画面の戻り先を自分で開く必要はありません。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Standard Tier の API は、Strava の有料サブスクが必要です。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                '2. Client ID と Client Secret を上に入れる',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'このアプリでは Access Token は使いません。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                '3. 「連携する」を押す',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Chrome が自動で開きます。許可すると 127.0.0.1 に案内が出ます。'
                'その画面を閉じることが必須です。閉じないと、連携ボタンは灰色のままです。'
                'アプリが手前に切り替わることはありません。この画面を見て、連携ボタンが緑に戻り「連携済み」になれば成功です。'
                '走行の取得はホームの「Strava同期」から。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                '4. Chrome が自動で開かないとき',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '「連携する」のあとに出る「許可用 URL をコピー」を Chrome のアドレス欄に貼って開きます。'
                'あとは 3 と同じく、案内の画面を閉じると連携ボタンが緑に戻ります。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _connect() async {
    final clientId = _clientId.text.trim();
    final clientSecret = _clientSecret.text.trim();
    if (clientId.isEmpty || clientSecret.isEmpty) {
      setState(() => _message = 'Client ID と Client Secret を入力してください。');
      return;
    }
    setState(() {
      _busy = true;
      _message = 'Chrome で Strava の許可を待っています…';
      _waitingBrowser = true;
      _browserFailedToOpen = false;
    });
    await widget.store.saveStravaCredentials(
      clientId: clientId,
      clientSecret: clientSecret,
    );
    _state = newOAuthState();
    final url = stravaAuthorizeUrl(clientId: clientId, state: _state!);
    _authorizeUrl = url;
    _listener = StravaLoopbackListener();
    try {
      await _listener!.start();
    } on SocketException {
      setState(() {
        _busy = false;
        _waitingBrowser = false;
        _message = 'ポート $stravaListenPort を開けませんでした。他のプロセスを終了して、もう一度連携してください。';
      });
      return;
    }
    final opened = await openInBrowser(url);
    if (mounted) {
      setState(() {
        _browserFailedToOpen = !opened;
        _message = opened
            ? 'Chrome に案内が出たら、その画面を閉じてください。連携ボタンが緑に戻れば成功です。'
            : 'Chrome が自動では開きませんでした。下の URL をコピーして Chrome で開いてください。';
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
      _message = 'トークンを端末に保存しました（${result.athleteName}）。';
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
      _message = '連携を解除し、トークンを消しました。';
    });
  }
}

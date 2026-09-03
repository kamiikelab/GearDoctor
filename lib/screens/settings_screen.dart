import 'package:flutter/material.dart';

import '../app_version.dart';
import '../l10n/app_localizations.dart';
import '../state/app_store.dart';
import '../strava/open_browser.dart';
import '../widgets/widgets.dart';
import 'gear_screen.dart';
import 'sync_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _message;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final localeCode = widget.store.settings.localeCode;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settings)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.language, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              SelectTile(
                selected: localeCode == null,
                title: l10n.languageSystem,
                onTap: () => widget.store.setLocaleCode(null),
              ),
              const SizedBox(height: 8),
              SelectTile(
                selected: localeCode == 'ja',
                title: l10n.languageJapanese,
                onTap: () => widget.store.setLocaleCode('ja'),
              ),
              const SizedBox(height: 8),
              SelectTile(
                selected: localeCode == 'en',
                title: l10n.languageEnglish,
                onTap: () => widget.store.setLocaleCode('en'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SyncScreen(store: widget.store),
                    ),
                  );
                },
                child: Text(l10n.stravaSync),
              ),
              const SizedBox(height: 16),
              Text(l10n.gear, style: Theme.of(context).textTheme.bodySmall),
              Text(
                l10n.gearHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GearScreen(store: widget.store),
                    ),
                  );
                },
                child: Text(l10n.gear),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.resetSection,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                l10n.resetHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : _confirmResetToDemo,
                child: Text(l10n.resetToDemo),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(_message!),
              ],
              const SizedBox(height: 24),
              Text(
                appVersionLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _openPrivacyPolicy,
                  child: Text(l10n.privacyPolicy),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final opened = await openInBrowser(privacyPolicyUri(lang));
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotOpenBrowser)),
      );
    }
  }

  Future<void> _confirmResetToDemo() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.resetConfirmTitle),
          content: Text(l10n.resetConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.resetConfirmAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    await widget.store.resetToDemo();
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _message = AppLocalizations.of(context).resetDone;
    });
  }
}

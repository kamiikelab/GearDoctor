import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'state/app_store.dart';
import 'theme.dart';

class GearDoctorApp extends StatefulWidget {
  const GearDoctorApp({super.key, this.store});

  final AppStore? store;

  @override
  State<GearDoctorApp> createState() => _GearDoctorAppState();
}

class _GearDoctorAppState extends State<GearDoctorApp> {
  late final AppStore _store;
  late final bool _ownsStore;

  @override
  void initState() {
    super.initState();
    _ownsStore = widget.store == null;
    _store = widget.store ??
        AppStore(
          deviceLocale:
              WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
                      'ja'
                  ? 'ja'
                  : 'en',
        );
    if (_ownsStore) {
      _store.load();
    }
  }

  @override
  void dispose() {
    if (_ownsStore) {
      _store.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final code = _store.settings.localeCode;
        return MaterialApp(
          title: 'GearDoctor',
          theme: buildAppTheme(),
          locale: switch (code) {
            'ja' => const Locale('ja'),
            'en' => const Locale('en'),
            _ => null,
          },
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          localeResolutionCallback: (locale, _) {
            if (code == 'ja') {
              return const Locale('ja');
            }
            if (code == 'en') {
              return const Locale('en');
            }
            if (locale?.languageCode == 'ja') {
              return const Locale('ja');
            }
            return const Locale('en');
          },
          home: Builder(
            builder: (context) {
              if (_store.loading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (_store.error != null) {
                final l10n = AppLocalizations.of(context);
                return Scaffold(
                  body: Center(
                    child: Text(l10n.startupFailed(_store.error!)),
                  ),
                );
              }
              return HomeScreen(store: _store);
            },
          ),
        );
      },
    );
  }
}

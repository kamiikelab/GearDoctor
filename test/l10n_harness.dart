import 'package:flutter/material.dart';
import 'package:gear_doctor/l10n/app_localizations.dart';

Widget l10nApp({
  required Widget home,
  Locale locale = const Locale('ja'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

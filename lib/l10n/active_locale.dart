import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

String activeLanguageCode = 'ja';

String supportedLanguageCode(String? code) {
  switch (code) {
    case 'ja':
    case 'en':
    case 'fr':
      return code!;
    default:
      return 'en';
  }
}

void setActiveLanguageCode(String? code) {
  activeLanguageCode = supportedLanguageCode(code);
}

AppLocalizations get activeL10n =>
    lookupAppLocalizations(Locale(activeLanguageCode));

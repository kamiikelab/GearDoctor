const appName = 'GearDoctor';
const appVersion = '1.0.4';
const privacyPolicyPage =
    'https://kamiikelab.github.io/GearDoctor/privacy-policy.html';

String get appVersionLabel => '$appName $appVersion';

Uri privacyPolicyUri(String languageCode) {
  final lang = languageCode == 'ja' ? 'ja' : 'en';
  return Uri.parse(privacyPolicyPage).replace(queryParameters: {'lang': lang});
}

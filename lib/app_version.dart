const appName = 'GearDoctor';
const privacyPolicyPage =
    'https://kamiikelab.github.io/GearDoctor/privacy-policy.html';

Uri privacyPolicyUri(String languageCode) {
  final lang = switch (languageCode) {
    'ja' => 'ja',
    'fr' => 'fr',
    _ => 'en',
  };
  return Uri.parse(privacyPolicyPage).replace(queryParameters: {'lang': lang});
}

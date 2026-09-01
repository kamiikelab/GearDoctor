import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'strava_config.dart';
import 'strava_oauth.dart';

/// iOS / Android で認可画面を開き、カスタム URL でコードを受け取る。
Future<Uri> authenticateStravaInAppBrowser(Uri authorizeUrl) async {
  try {
    final result = await FlutterWebAuth2.authenticate(
      url: authorizeUrl.toString(),
      callbackUrlScheme: stravaCallbackScheme,
    );
    return Uri.parse(result);
  } on PlatformException catch (e) {
    if (e.code.toUpperCase() == 'CANCELED' ||
        e.code.toUpperCase() == 'CANCELLED') {
      throw StravaAuthException('認可が取り消されました');
    }
    throw StravaAuthException(
      e.message ?? 'ブラウザでの認可に失敗しました（${e.code}）',
    );
  }
}

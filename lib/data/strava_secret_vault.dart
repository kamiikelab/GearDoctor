import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores Strava Client ID, Client Secret, and OAuth tokens outside SQLite.
///
/// On Android this is EncryptedSharedPreferences with a Keystore-backed key
/// (AES-GCM). Other platforms keep using SQLite unless a vault is injected.
abstract class StravaSecretVault {
  Future<String?> readClientId();
  Future<String?> readClientSecret();
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> write({
    String? clientId,
    String? clientSecret,
    String? accessToken,
    String? refreshToken,
  });
  Future<void> clear();
}

StravaSecretVault? platformStravaSecretVault() {
  if (Platform.isAndroid || Platform.isIOS) {
    return FlutterStravaSecretVault();
  }
  return null;
}

class MemoryStravaSecretVault implements StravaSecretVault {
  String? _clientId;
  String? _clientSecret;
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<String?> readClientId() async => _clientId;

  @override
  Future<String?> readClientSecret() async => _clientSecret;

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<void> write({
    String? clientId,
    String? clientSecret,
    String? accessToken,
    String? refreshToken,
  }) async {
    _clientId = _emptyToNull(clientId);
    _clientSecret = _emptyToNull(clientSecret);
    _accessToken = _emptyToNull(accessToken);
    _refreshToken = _emptyToNull(refreshToken);
  }

  @override
  Future<void> clear() async {
    _clientId = null;
    _clientSecret = null;
    _accessToken = null;
    _refreshToken = null;
  }
}

class FlutterStravaSecretVault implements StravaSecretVault {
  FlutterStravaSecretVault({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(storageNamespace: 'geardoctor_strava'),
            );

  static const _idKey = 'strava_client_id';
  static const _secretKey = 'strava_client_secret';
  static const _accessKey = 'strava_access_token';
  static const _refreshKey = 'strava_refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readClientId() async => _emptyToNull(await _storage.read(key: _idKey));

  @override
  Future<String?> readClientSecret() async =>
      _emptyToNull(await _storage.read(key: _secretKey));

  @override
  Future<String?> readAccessToken() async =>
      _emptyToNull(await _storage.read(key: _accessKey));

  @override
  Future<String?> readRefreshToken() async =>
      _emptyToNull(await _storage.read(key: _refreshKey));

  @override
  Future<void> write({
    String? clientId,
    String? clientSecret,
    String? accessToken,
    String? refreshToken,
  }) async {
    await _write(_idKey, clientId);
    await _write(_secretKey, clientSecret);
    await _write(_accessKey, accessToken);
    await _write(_refreshKey, refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _idKey);
    await _storage.delete(key: _secretKey);
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  Future<void> _write(String key, String? value) async {
    final stored = _emptyToNull(value);
    if (stored == null) {
      await _storage.delete(key: key);
      return;
    }
    await _storage.write(key: key, value: stored);
  }
}

String? _emptyToNull(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}

import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores Strava Client ID and Client Secret outside the SQLite settings table.
///
/// On Android this is EncryptedSharedPreferences with a Keystore-backed key
/// (AES-GCM). Other platforms keep using SQLite unless a vault is injected.
abstract class StravaSecretVault {
  Future<String?> readClientId();
  Future<String?> readClientSecret();
  Future<void> write({String? clientId, String? clientSecret});
  Future<void> clear();
}

StravaSecretVault? platformStravaSecretVault() {
  if (Platform.isAndroid) {
    return FlutterStravaSecretVault();
  }
  return null;
}

class MemoryStravaSecretVault implements StravaSecretVault {
  String? _clientId;
  String? _clientSecret;

  @override
  Future<String?> readClientId() async => _clientId;

  @override
  Future<String?> readClientSecret() async => _clientSecret;

  @override
  Future<void> write({String? clientId, String? clientSecret}) async {
    _clientId = _emptyToNull(clientId);
    _clientSecret = _emptyToNull(clientSecret);
  }

  @override
  Future<void> clear() async {
    _clientId = null;
    _clientSecret = null;
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

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readClientId() async => _emptyToNull(await _storage.read(key: _idKey));

  @override
  Future<String?> readClientSecret() async =>
      _emptyToNull(await _storage.read(key: _secretKey));

  @override
  Future<void> write({String? clientId, String? clientSecret}) async {
    await _write(_idKey, clientId);
    await _write(_secretKey, clientSecret);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _idKey);
    await _storage.delete(key: _secretKey);
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

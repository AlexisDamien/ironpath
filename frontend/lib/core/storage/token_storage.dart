import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _rememberSessionKey = 'remember_session';

  final FlutterSecureStorage _secureStorage;

  String? _sessionAccessToken;
  String? _sessionRefreshToken;
  bool? _rememberSession;

  TokenStorage(this._secureStorage);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    bool persist = true,
  }) async {
    _sessionAccessToken = accessToken;
    _sessionRefreshToken = refreshToken;
    _rememberSession = persist;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_rememberSessionKey, persist);

    if (kIsWeb) {
      if (persist) {
        await preferences.setString(_accessTokenKey, accessToken);
        await preferences.setString(_refreshTokenKey, refreshToken);
      } else {
        await preferences.remove(_accessTokenKey);
        await preferences.remove(_refreshTokenKey);
      }
      return;
    }

    if (persist) {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    } else {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    }
  }

  Future<bool> shouldRestoreSession() async {
    if (_rememberSession != null) return _rememberSession!;

    final preferences = await SharedPreferences.getInstance();

    // Les anciennes versions stockaient déjà les jetons sans enregistrer
    // explicitement ce choix. Par défaut, on tente donc une restauration.
    _rememberSession = preferences.getBool(_rememberSessionKey) ?? true;
    return _rememberSession!;
  }

  Future<String?> getAccessToken() async {
    if (_sessionAccessToken != null && _sessionAccessToken!.isNotEmpty) {
      return _sessionAccessToken;
    }

    if (!await shouldRestoreSession()) return null;

    if (kIsWeb) {
      final preferences = await SharedPreferences.getInstance();
      _sessionAccessToken = preferences.getString(_accessTokenKey);
    } else {
      _sessionAccessToken = await _secureStorage.read(key: _accessTokenKey);
    }

    return _sessionAccessToken;
  }

  Future<String?> getRefreshToken() async {
    if (_sessionRefreshToken != null && _sessionRefreshToken!.isNotEmpty) {
      return _sessionRefreshToken;
    }

    if (!await shouldRestoreSession()) return null;

    if (kIsWeb) {
      final preferences = await SharedPreferences.getInstance();
      _sessionRefreshToken = preferences.getString(_refreshTokenKey);
    } else {
      _sessionRefreshToken = await _secureStorage.read(key: _refreshTokenKey);
    }

    return _sessionRefreshToken;
  }

  Future<void> clearTokens() async {
    _sessionAccessToken = null;
    _sessionRefreshToken = null;
    _rememberSession = false;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_rememberSessionKey, false);
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);

    if (!kIsWeb) {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    }
  }
}

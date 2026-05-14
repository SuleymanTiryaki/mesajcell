import 'dart:convert';

/// Uygulama oturumu — token ve kullanıcı bilgilerini bellekte tutar.
/// OTP doğrulama başarılı olduğunda set edilir.
final class AppSession {
  AppSession._();

  static final AppSession _instance = AppSession._();
  static AppSession get instance => _instance;

  String? _accessToken;
  String? _refreshToken;
  String? _userId;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userId => _userId;

  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;

  void setTokens({required String accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = _parseSubFromJwt(accessToken);
  }

  void clear() {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
  }

  /// JWT'nin payload kısmındaki `sub` veya `user_id` alanını okur.
  static String? _parseSubFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded) as Map<String, dynamic>;
      return payload['sub'] as String? ?? payload['user_id'] as String?;
    } catch (_) {
      return null;
    }
  }
}


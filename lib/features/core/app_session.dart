/// Uygulama oturumu — token ve kullanıcı bilgilerini bellekte tutar.
/// OTP doğrulama başarılı olduğunda set edilir.
final class AppSession {
  AppSession._();

  static final AppSession _instance = AppSession._();
  static AppSession get instance => _instance;

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;

  void setTokens({required String accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void clear() {
    _accessToken = null;
    _refreshToken = null;
  }
}

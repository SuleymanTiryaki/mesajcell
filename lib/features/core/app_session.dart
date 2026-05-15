import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama oturumu — token ve kullanıcı bilgilerini hem bellekte hem
/// SharedPreferences'ta tutar. Uygulama yeniden açılınca initFromStorage()
/// ile geri yüklenir.
final class AppSession {
  AppSession._();

  static final AppSession _instance = AppSession._();
  static AppSession get instance => _instance;

  // ─── In-memory state ──────────────────────────────────────────────────────
  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _orgId;
  String? _role;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userId => _userId;
  String? get orgId => _orgId;
  String? get role => _role;

  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;
  bool get isOrgAdmin => _role == 'ORG_ADMIN';

  // ─── SharedPreferences keys ───────────────────────────────────────────────
  static const _kAccess  = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUserId  = 'user_id';
  static const _kOrgId   = 'org_id';
  static const _kRole    = 'role';

  // ─── Init (uygulama açılışında çağır) ─────────────────────────────────────
  Future<void> initFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken  = prefs.getString(_kAccess);
    _refreshToken = prefs.getString(_kRefresh);
    _userId       = prefs.getString(_kUserId);
    _orgId        = prefs.getString(_kOrgId);
    _role         = prefs.getString(_kRole);
  }

  // ─── Kaydet ───────────────────────────────────────────────────────────────
  Future<void> setTokens({
    required String accessToken,
    String? refreshToken,
    String? userId,
    String? orgId,
    String? role,
  }) async {
    _accessToken  = accessToken;
    _refreshToken = refreshToken ?? _refreshToken;
    _userId       = userId       ?? _parseSubFromJwt(accessToken);
    _orgId        = orgId        ?? _orgId;
    _role         = role         ?? _role;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, _accessToken!);
    if (_refreshToken != null) await prefs.setString(_kRefresh, _refreshToken!);
    if (_userId  != null) await prefs.setString(_kUserId, _userId!);
    if (_orgId   != null) await prefs.setString(_kOrgId,  _orgId!);
    if (_role    != null) await prefs.setString(_kRole,   _role!);
  }

  // ─── Temizle ──────────────────────────────────────────────────────────────
  Future<void> clear() async {
    _accessToken  = null;
    _refreshToken = null;
    _userId       = null;
    _orgId        = null;
    _role         = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
    await prefs.remove(_kUserId);
    await prefs.remove(_kOrgId);
    await prefs.remove(_kRole);
  }

  // ─── JWT payload'dan sub/user_id ──────────────────────────────────────────
  static String? _parseSubFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded) as Map<String, dynamic>;
      return payload['sub']?.toString() ?? payload['user_id']?.toString();
    } catch (_) {
      return null;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'app_logger.dart';
import 'app_session.dart';

final class AppDio {
  AppDio._();

  static Dio create({String? baseUrl}) {
    final base = baseUrl ?? dotenv.env['BASE_URL'] ?? '';

    final dio = Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // ── Bearer token ──────────────────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AppSession.instance.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },

        // ── 401 → refresh → retry ─────────────────────────────────────────
        onError: (err, handler) async {
          if (err.response?.statusCode == 401) {
            final refreshed = await _tryRefresh(base);
            if (refreshed) {
              // Aynı isteği yeni token ile tekrar gönder
              try {
                final opts = err.requestOptions;
                opts.headers['Authorization'] =
                    'Bearer ${AppSession.instance.accessToken}';
                final retryDio = Dio(BaseOptions(baseUrl: base));
                final response = await retryDio.fetch(opts);
                return handler.resolve(response);
              } catch (_) {}
            }
            // Refresh başarısız → oturumu temizle (router yönlendirecek)
            await AppSession.instance.clear();
          }
          handler.next(err);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: false,
          maxWidth: 90,
        ),
      );
    }

    return dio;
  }

  // ── Token yenileme ────────────────────────────────────────────────────────
  static Future<bool> _tryRefresh(String baseUrl) async {
    final refresh = AppSession.instance.refreshToken;
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final plain = Dio(BaseOptions(baseUrl: baseUrl));
      final res = await plain.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final data = res.data as Map?;
      final accessToken = data?['data']?['access_token'] as String?;
      if (accessToken != null && accessToken.isNotEmpty) {
        await AppSession.instance.setTokens(accessToken: accessToken);
        AppLogger.i('[AppDio] Token yenilendi');
        return true;
      }
    } catch (e) {
      AppLogger.e('[AppDio] Refresh başarısız: $e');
    }
    return false;
  }
}

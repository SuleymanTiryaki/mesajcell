import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Merkezi Dio factory — tüm servisler buradan Dio alır.
/// Debug modda request/response konsola yazdırılır.
final class AppDio {
  AppDio._();

  static Dio create({String? baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? dotenv.env['BASE_URL'] ?? '',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
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
          filter: (options, args) {
            // Hassas header'ları gizle (Authorization, Cookie)
            if (args.isResponse) return true;
            final headers = options.headers;
            if (headers.containsKey('Authorization')) {
              headers['Authorization'] = '***';
            }
            return true;
          },
        ),
      );
    }

    return dio;
  }
}

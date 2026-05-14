import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class BaseDioService {
  BaseDioService._();
  static final BaseDioService service = BaseDioService._();

  String handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
      case DioExceptionType.connectionTimeout:
        return 'Bağlantı zaman aşımına uğradı.';
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Sunucu yanıt vermiyor, lütfen tekrar deneyin.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        // Önce API'nin kendi mesajını okumaya çalış
        final data = e.response?.data;
        String? apiMessage;
        if (data is Map) {
          apiMessage = data['message'] as String? ?? data['error'] as String?;
        } else if (data is String && data.isNotEmpty) {
          apiMessage = data;
        }
        if (apiMessage != null && apiMessage.isNotEmpty) return apiMessage;
        if (statusCode == 401) return 'Yetkisiz işlem.';
        if (statusCode == 404) return 'Servis bulunamadı.';
        if (statusCode == 409) return 'Bu bilgilerle kayıtlı bir hesap zaten mevcut.';
        if (statusCode == 422) return 'Gönderilen veriler geçersiz, lütfen kontrol edin.';
        if (statusCode != null && statusCode >= 500) {
          return 'Sunucu hatası (#$statusCode).';
        }
        return 'Bir hata oluştu (#$statusCode).';
      default:
        return 'Beklenmeyen bir hata oluştu.';
    }
  }
}

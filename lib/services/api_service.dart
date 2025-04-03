import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl =
      'https://express-lirisflora-api.onrender.com/api'; // Cập nhật base URL
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(
      seconds: 15,
    ); // Tăng timeout vì render.com có thể chậm
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.contentType = 'application/json';

    // Thêm interceptor để log và debug
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
  }

  // GET request
  Future<Response> getRequest(
    String endpoint, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      // Đảm bảo headers được chuyển đổi thành đúng định dạng
      Map<String, dynamic> finalHeaders = headers ?? {};

      // Debug
      print("Final headers for GET request: $finalHeaders");
      print("Full URL: ${_dio.options.baseUrl}$endpoint");

      Options options = Options(headers: finalHeaders);

      return await _dio.get(endpoint, options: options);
    } catch (e) {
      print("GET Error: $e");
      if (e is DioException) {
        print("Status code: ${e.response?.statusCode}");
        print("Response data: ${e.response?.data}");
        print("Request data: ${e.requestOptions.data}");
        print("Request headers: ${e.requestOptions.headers}");
        print("Request path: ${e.requestOptions.path}");
      }
      rethrow;
    }
  }

  // POST request
  Future<Response> postRequest(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      // Đảm bảo headers được chuyển đổi thành đúng định dạng
      Map<String, dynamic> finalHeaders = headers ?? {};

      // Debug
      print("Final headers for POST request: $finalHeaders");
      print("Full URL: ${_dio.options.baseUrl}$endpoint");
      print("Request data: $data");

      Options options = Options(headers: finalHeaders);

      return await _dio.post(endpoint, data: data, options: options);
    } catch (e) {
      print("POST Error: $e");
      if (e is DioException) {
        print("Status code: ${e.response?.statusCode}");
        print("Response data: ${e.response?.data}");
        print("Request data: ${e.requestOptions.data}");
        print("Request headers: ${e.requestOptions.headers}");
        print("Request path: ${e.requestOptions.path}");
      }
      rethrow;
    }
  }

  // PUT request
  Future<Response> putRequest(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      Map<String, dynamic> finalHeaders = headers ?? {};
      Options options = Options(headers: finalHeaders);

      return await _dio.put(endpoint, data: data, options: options);
    } catch (e) {
      print("PUT Error: $e");
      rethrow;
    }
  }

  // DELETE request
  Future<Response> deleteRequest(
    String endpoint, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      Map<String, dynamic> finalHeaders = headers ?? {};
      Options options = Options(headers: finalHeaders);

      return await _dio.delete(endpoint, options: options);
    } catch (e) {
      print("DELETE Error: $e");
      rethrow;
    }
  }

  // Phương thức để thiết lập token cho tất cả các request
  Future<void> setAuthToken() async {
    String? token = await _storage.read(key: 'accessToken');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }
}

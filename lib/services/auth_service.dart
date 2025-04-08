import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class RegisterLoginService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Hàm đăng ký người dùng (giữ nguyên)
  Future<Response> registerUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      };
      Response response = await _apiService.postRequest('/v1/register', data);
      print("Phản hồi từ server: ${response.data}");
      return response;
    } catch (e) {
      print("Lỗi đăng ký: $e");
      return Response(
        requestOptions: RequestOptions(path: '/register'),
        statusCode: 500,
        data: {"message": "Lỗi đăng ký"},
      );
    }
  }

  // Hàm đăng nhập người dùng (đã cải tiến)
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      Response response = await _apiService.postRequest('/v1/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data != null) {
        String accessToken = response.data['accessToken'];
        print('AccessToken đã nhận được: $accessToken');

        await _storage.write(key: 'accessToken', value: accessToken);

        Map<String, String> headers = {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

        print('Gửi request đến /v1/current_user với headers: $headers');

        Response userResponse = await _apiService.getRequest(
          '/v1/current_user',
          headers: headers,
        );

        if (userResponse.statusCode == 200 && userResponse.data != null) {
          print("Phản hồi từ /v1/current_user: ${userResponse.data}");

          Map<String, dynamic> user;
          if (userResponse.data is Map &&
              userResponse.data.containsKey('user')) {
            user = userResponse.data['user'];
          } else {
            user = userResponse.data;
          }

          print("Thông tin người dùng: $user");
          await _storage.write(key: 'user', value: json.encode(user));
          print("Thông tin người dùng đã lưu vào storage: $user");
          return user;
        } else {
          print(
            "Lỗi khi lấy thông tin người dùng: ${userResponse.statusCode} - ${userResponse.data}",
          );
          return {
            'statusCode': userResponse.statusCode,
            'error': 'Failed to fetch user information: ${userResponse.data}',
          };
        }
      } else {
        print(
          "Phản hồi không hợp lệ từ /v1/login: ${response.statusCode} - ${response.data}",
        );
        return {
          'statusCode': response.statusCode,
          'error': response.data.toString(), // Chuỗi thô hoặc dữ liệu khác
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Lỗi kết nối: ${e.response?.statusCode}');
        print('Thông báo lỗi từ server: ${e.response?.data}');

        String errorMessage;
        if (e.response?.data is String) {
          errorMessage =
              e.response?.data; // Chuỗi thô như "Invalid email or password"
        } else if (e.response?.data is Map) {
          errorMessage = e.response?.data['error'] ?? 'Unknown error';
        } else {
          errorMessage = 'Unknown error';
        }

        return {'statusCode': e.response?.statusCode, 'error': errorMessage};
      } else {
        print('Lỗi không có phản hồi: ${e.message}');
        return {
          'statusCode': 0,
          'error': 'No response from server: ${e.message}',
        };
      }
    } catch (e) {
      print("Lỗi không xác định: $e");
      return {'statusCode': 500, 'error': 'Unexpected error: $e'};
    }
  }

  // Hàm đăng xuất người dùng (giữ nguyên)
  Future<void> logoutUser() async {
    try {
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'user');
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
    }
  }
}

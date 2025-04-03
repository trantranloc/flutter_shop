import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class RegisterLoginService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Hàm đăng ký người dùng
  Future<Response> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      Map<String, dynamic> data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      };
      // Sử dụng URL đầy đủ cho API đăng ký
      Response response = await _apiService.postRequest(
        '/v1/register', // URL đăng ký
        data,
      );
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

  // Hàm đăng nhập người dùng
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Gọi API đăng nhập thông qua _apiService
      Response response = await _apiService.postRequest(
        '/v1/login', // Đường dẫn API đăng nhập
        {'email': email, 'password': password},
      );

      // Kiểm tra phản hồi từ API đăng nhập
      if (response.statusCode == 200 && response.data != null) {
        String accessToken = response.data['accessToken'];
        print('AccessToken đã nhận được: $accessToken');

        // Lưu accessToken vào Flutter Secure Storage
        await _storage.write(key: 'accessToken', value: accessToken);

        try {
          // Đảm bảo header được đặt đúng cách - thử với cả hai định dạng phổ biến
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
            // Kiểm tra cấu trúc phản hồi
            print("Phản hồi từ /v1/current_user: ${userResponse.data}");

            // Lấy thông tin user từ phản hồi dựa vào cấu trúc của API
            Map<String, dynamic> user;
            if (userResponse.data is Map &&
                userResponse.data.containsKey('user')) {
              user = userResponse.data['user'];
            } else {
              user = userResponse.data;
            }

            print("Thông tin người dùng: $user");
            // Lưu thông tin user vào secure storage
            await _storage.write(key: 'user', value: json.encode(user));
            print("Thông tin người dùng đã lưu vào storage: $user");
            return user;
          } else {
            print(
              "Lỗi khi lấy thông tin người dùng: ${userResponse.statusCode} - ${userResponse.data}",
            );
            return {
              'error': 'Failed to fetch user information: ${userResponse.data}',
            };
          }
        } catch (e) {
          print("Lỗi khi lấy thông tin người dùng: $e");
          return {'error': 'Error getting user info: $e'};
        }
      } else if (response.statusCode == 401) {
        return {'error': 'Invalid email or password'};
      } else {
        return {'error': 'Unexpected error: ${response.statusCode}'};
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  // Hàm đăng xuất người dùng
  Future<void> logoutUser() async {
    try {
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'user');
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
    }
  }
}

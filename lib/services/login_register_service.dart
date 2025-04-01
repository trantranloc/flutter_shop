import 'package:dio/dio.dart';
import '../services/api_service.dart';

class RegisterLoginService {
  final ApiService _apiService = ApiService();

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
  Future<Response> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> data = {
        'email': email,
        'password': password,
      };
      // Sử dụng URL đầy đủ cho API đăng nhập
      Response response = await _apiService.postRequest(
        '/v1/login', // URL đăng nhập
        data,
      );
      print("Phản hồi từ server: ${response.data}");
      return response;
    } catch (e) {
      print("Lỗi đăng nhập: $e");
      return Response(
        requestOptions: RequestOptions(path: '/login'),
        statusCode: 500,
        data: {"message": "Lỗi đăng nhập"},
      );
    }
  }
}

import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: "https://express-lirisflora-api.onrender.com/api", // Địa chỉ API Backend
    connectTimeout: Duration(seconds: 20000), // Thời gian timeout kết nối
    receiveTimeout: Duration(seconds: 20000), // Thời gian timeout nhận dữ liệu
    headers: {"Content-Type": "application/json"}, // Đảm bảo gửi dữ liệu đúng định dạng
  ));

  // GET request
  Future<Response> getRequest(String endpoint) async {
    try {
      return await dio.get(endpoint);
    } on DioException catch (e) {
      print("❌ Lỗi GET $endpoint: ${e.response?.data ?? e.message}");
      return Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data ?? {"error": "Lỗi không xác định"},
      );
    }
  }

  // POST request
  Future<Response> postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      return await dio.post(endpoint, data: data);
    } on DioException catch (e) {
      print("❌ Lỗi POST $endpoint: ${e.response?.data ?? e.message}");
      return Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data ?? {"error": "Lỗi không xác định"},
      );
    }
  }
}

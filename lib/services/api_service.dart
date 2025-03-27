import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(baseUrl: "https://express-lirisflora-api.onrender.com/api"));

  Future<Response> getRequest(String endpoint) async {
    try {
      return await dio.get(endpoint);
    } catch (e) {
      print("Lỗi GET $endpoint: $e");
      return Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: 500,
      );
    }
  }
}

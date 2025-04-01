import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://express-lirisflora-api.onrender.com/api",
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

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

  Future<Response> putRequest(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      return await dio.put(endpoint, data: data);
    } catch (e) {
      print("Lỗi PUT $endpoint: $e");
      return Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: 500,
      );
    }
  }

  Future<Response> deleteRequest(String endpoint) async {
    try {
      return await dio.delete(endpoint);
    } catch (e) {
      print("Lỗi DELETE $endpoint: $e");
      return Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: 500,
      );
    }
  }

  Future<Response> postRequest(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      return await dio.post(endpoint, data: data);
    } catch (e) {
      print("Lỗi POST $endpoint: $e");
      return Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: 500,
      );
    }
  }
}

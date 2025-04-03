import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/product.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  Future<List<Product>> fetchProducts() async {
    Response response = await _apiService.getRequest("/product", headers: {});
    if (response.statusCode == 200) {
      List data = response.data['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  }
}

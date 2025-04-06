import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/category.dart';

class CategoryService {
  final ApiService _apiService = ApiService();
  List<Category> _cachedCategories = [];

  Future<List<Category>> fetchCategories() async {
    try {
      Response response = await _apiService.getRequest("/category");

      if (response.statusCode == 200) {
        List data = response.data['data'];
        _cachedCategories =
            data.map((json) => Category.fromJson(json)).toList();
        // print("Fetched categories: $_cachedCategories");
        return _cachedCategories;
      } else {
        // print("Error fetching categories: Status ${response.statusCode}");
        // If we have cached categories and the request failed, return the cached data
        if (_cachedCategories.isNotEmpty) {
          return _cachedCategories;
        }
        return [];
      }
    } catch (e) {
      print("Exception fetching : $e");
      if (_cachedCategories.isNotEmpty) {
        return _cachedCategories;
      }
      return [];
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../models/category.dart';

class CategoryService {
  final ApiService _apiService = ApiService();
  List<Category> _cachedCategories = [];
  DateTime? _lastFetchTime;
  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Khởi tạo FlutterSecureStorage

  Future<List<Category>> fetchCategories({bool forceRefresh = false}) async {
    // Return cached categories if they exist and are recent (less than 5 minutes old)
    // unless forceRefresh is true
    if (!forceRefresh &&
        _cachedCategories.isNotEmpty &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 5) {
      return _cachedCategories;
    }

    try {
      String? accessToken = await _storage.read(key: 'accessToken');
      Response response = await _apiService.getRequest(
        "/category",
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        List data = response.data['data'];
        _cachedCategories =
            data.map((json) => Category.fromJson(json)).toList();
        _lastFetchTime = DateTime.now();
        return _cachedCategories;
      } else {
        print("Error fetching categories: Status ${response.statusCode}");
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

  // Get a specific category by ID
  Future<Category?> getCategoryById(String id) async {
    // First try to find it in the cache
    if (_cachedCategories.isNotEmpty) {
      try {
        return _cachedCategories.firstWhere((category) => category.id == id);
      } catch (e) {
        // Not found in cache, continue to API call
      }
    }

    try {
      String? accessToken = await _storage.read(key: 'accessToken');
      Response response = await _apiService.getRequest(
        "/category/$id",
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data['data'];
        return Category.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Exception getting category by ID: $e");
      return null;
    }
  }

  // Get a list of category names
  Future<List<String>> getCategoryNames() async {
    List<Category> categories = await fetchCategories();
    return categories.map((category) => category.name).toList();
  }

  // Clear the cache to force a fresh fetch
  void clearCache() {
    _cachedCategories = [];
    _lastFetchTime = null;
  }
}

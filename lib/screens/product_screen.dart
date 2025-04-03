import 'package:flutter/material.dart';
import 'package:flutter_shop/services/product_service.dart';
import 'package:flutter_shop/services/category_service.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../widgets/product_card.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tải danh sách danh mục từ API
      final categories = await _categoryService.fetchCategories();

      // Tải danh sách sản phẩm từ API
      final products = await _productService.fetchProducts();

      setState(() {
        _categories = categories;
        _products = products;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tải dữ liệu: $e')));
    }
  }

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredProducts =
        _products.where((product) {
          // First check if the product matches the search query
          bool matchesSearch =
              _searchQuery.isEmpty ||
              product.name.toLowerCase().contains(_searchQuery.toLowerCase());

          // Then check if it matches the selected category
          bool matchesCategory =
              _selectedCategory == "All" ||
              product.category.name.toLowerCase() ==
                  _selectedCategory.toLowerCase(); // Fix here

          return matchesSearch && matchesCategory;
        }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pink.shade300,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              context.push('/cart').then((_) {
                _loadData();
              });
            },
          ),

          // IconButton(icon: Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onChanged: _searchProducts,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Widget lọc theo danh mục
          _buildCategoryFilter(),
          Flexible(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _filteredProducts.isEmpty
                    ? Center(
                      child: Text(
                        'Không tìm thấy sản phẩm',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                    : Padding(
                      padding: EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: _filteredProducts[index],
                            allProducts: _products,
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị danh sách category để lọc
  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(vertical: 8),
      child:
          _isLoading
              ? Center(child: CircularProgressIndicator(strokeWidth: 2))
              : ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8),
                children: [
                  // Thêm lựa chọn "All" đầu tiên
                  _buildCategoryChip("All"),
                  // Kiểm tra nếu _categories có dữ liệu
                  if (_categories.isNotEmpty)
                    ..._categories
                        .map((category) => _buildCategoryChip(category.name))
                        .toList(),
                ],
              ),
    );
  }

  Widget _buildCategoryChip(String categoryName) {
    final isSelected = _selectedCategory == categoryName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(categoryName),
        selected: isSelected,
        onSelected: (selected) {
          _filterByCategory(categoryName);
        },
        selectedColor: Colors.pink[100],
        checkmarkColor: Colors.pink,
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}

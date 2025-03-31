import 'package:flutter/material.dart';
import 'package:flutter_shop/services/product_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/category_filter.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    List<Product> products = await _productService.fetchProducts();
    setState(() {
      _products = products;
      _filteredProducts = products;
      _isLoading = false;
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts =
          _products
              .where(
                (product) =>
                    product.name.toLowerCase().contains(query.toLowerCase()) &&
                    (_selectedCategory == "All" ||
                        product.category == _selectedCategory),
              )
              .toList();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filteredProducts =
          _products
              .where(
                (product) =>
                    product.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) &&
                    (_selectedCategory == "All" ||
                        product.category == _selectedCategory),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pink.shade300,
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
          CategoryFilter(onCategorySelected: _filterByCategory),
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
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
                          return ProductCard(product: _filteredProducts[index]);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

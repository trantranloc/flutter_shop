import 'package:flutter/material.dart';
import 'package:flutter_shop/services/product_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    List<Product> products = await _productService.fetchProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sản phẩm'),
        backgroundColor: Colors.green[700],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Hiển thị loading khi tải dữ liệu
              : Padding(
                padding: EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Hiển thị 2 cột
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: _products[index]);
                  },
                ),
              ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  String searchQuery = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse('YOUR_API_ENDPOINT/products'));

    if (response.statusCode == 200) {
      setState(() {
        products =
            (json.decode(response.body) as List)
                .map((data) => Product.fromJson(data))
                .toList();
        filteredProducts = products;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchProduct(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts =
          products.where((product) {
            return product.name.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trang chủ')),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: _searchProduct,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Danh mục sản phẩm (Ví dụ)
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('Tất cả'),
                _buildCategoryChip('Điện thoại'),
                _buildCategoryChip('Laptop'),
                _buildCategoryChip('Phụ kiện'),
                _buildCategoryChip('Thời trang'),
              ],
            ),
          ),

          // Hiển thị danh sách sản phẩm
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredProducts.isEmpty
                    ? Center(child: Text('Không có sản phẩm nào'))
                    : GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị một sản phẩm
  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                product.images.first,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '\$${product.price}',
              style: TextStyle(color: Colors.green),
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  // Widget danh mục sản phẩm
  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ActionChip(
        label: Text(category),
        onPressed: () {
          // Xử lý lọc theo danh mục nếu cần
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_shop/services/product_service.dart';
import '../widgets/home_banner.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = true;

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
      final products = await _productService.fetchProducts();
      // print(products);

      setState(() {
        _products = products;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50], // 🌸 Màu nền hồng nhẹ
      appBar: AppBar(
        title: Text(
          "LIRIS'FELORA",
          style: TextStyle(
            fontFamily: 'CrimsonText-Italic', // Font chữ có chân
            fontWeight: FontWeight.w200, // Chữ mỏng
            fontStyle: FontStyle.italic, // Chữ in nghiêng
          ),
        ),
        backgroundColor: Colors.pink, // 🌸 Màu AppBar
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _products.isEmpty
              ? Center(child: Text('No products available'))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeBanner(),
                    SizedBox(height: 20),
                    _buildProductCarousel(),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "New Arrival Items",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink, // 🌸 Màu chữ
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildProductGrid(),
                  ],
                ),
              ),
    );
  }

  Widget _buildProductGrid() {
    // Calculate the number of products to display, with a maximum of 9
    final displayCount = _products.length > 9 ? 9 : _products.length;

    return GridView.builder(
      padding: EdgeInsets.all(10),
      shrinkWrap: true, // Allow the grid to take only the space it needs
      physics:
          NeverScrollableScrollPhysics(), // Disable scrolling of the grid itself
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7, // Tỷ lệ chiều rộng/chiều cao của mỗi ô
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        return ProductCard(
          product: _products[index],
          allProducts: _products,
        ); // 🛍️ Hiển thị sản phẩm
      },
    );
  }

  Widget _buildProductCarousel() {
    return CarouselSlider.builder(
      itemCount: _products.length,
      itemBuilder: (context, index, realIndex) {
        return _buildProductCard(_products[index]);
      },
      options: CarouselOptions(
        height: 300.0, // Chiều cao của carousel
        enlargeCenterPage: true, // Tạo hiệu ứng phóng to sản phẩm ở giữa
        autoPlay: true, // Tự động chuyển slide
        aspectRatio: 16 / 9, // Tỷ lệ hiển thị
        viewportFraction:
            0.8, // Hiển thị một chút sản phẩm kế tiếp để tạo hiệu ứng cuộn
        scrollPhysics: BouncingScrollPhysics(), // Hiệu ứng kéo mượt mà
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ảnh sản phẩm và tên, mô tả trên ảnh
        Stack(
          children: [
            // Hình ảnh sản phẩm
            Image.network(
              product.images[0],
              width: 300, // Kích thước ảnh
              height: 250, // Kích thước ảnh
              fit: BoxFit.cover,
            ),
            // Gradient mờ phía trên ảnh để chữ rõ hơn
            Container(
              width: 300, // Đảm bảo gradient phủ toàn bộ ảnh
              height: 250, // Đảm bảo gradient phủ toàn bộ ảnh
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3), // Mờ từ trên
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Tên sản phẩm
            Positioned(
              bottom: 40, // Khoảng cách từ dưới lên (tùy chỉnh)
              left: 10,
              right: 10,
              child: Text(
                product.name, // Giả sử sản phẩm có thuộc tính name
                style: TextStyle(
                  fontSize: 18, // Kích thước chữ cho tên sản phẩm
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Màu chữ trắng để nổi bật trên nền ảnh
                  fontStyle: FontStyle.italic, // Chữ in nghiêng
                ),
                textAlign: TextAlign.center, // Căn giữa chữ
              ),
            ),
            // Chi tiết sản phẩm
            Positioned(
              bottom: 10, // Khoảng cách từ dưới lên (tùy chỉnh)
              left: 10,
              right: 10,
              child: Text(
                product.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8), // Màu chữ mờ một chút
                ),
                textAlign: TextAlign.center, // Căn giữa chữ
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

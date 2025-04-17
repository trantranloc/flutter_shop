import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart'; // Import ProductCard widget

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final List<Product> allProducts; // Danh sách tất cả sản phẩm

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.allProducts,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách sản phẩm liên quan (cùng category nhưng không phải chính nó)
    List<Product> relatedProducts =
        widget.allProducts
            .where(
              (p) =>
                  p.category.name == widget.product.category.name &&
                  p.id != widget.product.id,
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.pink[300],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.product.images.isNotEmpty
                      ? widget.product.images.first
                      : 'https://via.placeholder.com/150',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Tên sản phẩm
            Text(
              widget.product.name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Giá sản phẩm
            Text(
              '\$${widget.product.price}',
              style: TextStyle(
                fontSize: 22,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            // Mô tả sản phẩm
            Text(
              widget.product.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),

            // Chọn số lượng sản phẩm
            Row(
              children: [
                Text(
                  "Quantity:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed:
                      () => setState(
                        () => _quantity = (_quantity > 1) ? _quantity - 1 : 1,
                      ),
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                ),
                Text(
                  '$_quantity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: Icon(Icons.add_circle, color: Colors.green),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Nút "Thêm vào giỏ hàng"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.product.name} đã được thêm vào giỏ hàng!',
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(Icons.shopping_cart),
                label: Text("Thêm vào giỏ hàng"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Hiển thị danh sách sản phẩm liên quan
            Text(
              "Related Products ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            relatedProducts.isNotEmpty
                ? GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: relatedProducts.length,
                  itemBuilder: (context, index) {
                    final relatedProduct = relatedProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailScreen(
                                  product: relatedProduct,
                                  allProducts: widget.allProducts,
                                ),
                          ),
                        );
                      },
                      child: ProductCard(
                        product: relatedProduct,
                        allProducts: widget.allProducts,
                      ),
                    );
                  },
                )
                : Text(""),
          ],
        ),
      ),
    );
  }
}

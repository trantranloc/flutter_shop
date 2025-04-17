import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../services/cart_service.dart'; // Import CartService
import '../widgets/product_card.dart'; // Import ProductCard widget

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final List<Product> allProducts; // List of all products

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
  bool _isFavorite = false; // Track favorite state
  final _cartService = CartService(); // Initialize CartService

  void _addToCart(BuildContext context) async {
    try {
      // Add the product to cart with selected quantity
      _cartService.addToCart(widget.product, _quantity);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} added to cart successfully!'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              GoRouter.of(context).go('/cart');
            },
          ),
          backgroundColor: Colors.pink.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter related products (same category, excluding current product)
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
        title: Text(
          widget.product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade300, Colors.pink.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite
                        ? '${widget.product.name} added to favorites!'
                        : '${widget.product.name} removed from favorites!',
                  ),
                  backgroundColor: _isFavorite ? Colors.pink : Colors.grey,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            tooltip: 'Favorite',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.product.images.isNotEmpty
                        ? widget.product.images.first
                        : 'https://via.placeholder.com/300',
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.pink.shade100,
                          child: Icon(
                            Icons.local_florist,
                            size: 100,
                            color: Colors.pink.shade300,
                          ),
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Name
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Product Price
            Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                color: Colors.pink.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Product Description
            Text(
              widget.product.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Selector
            Row(
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade100,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed:
                            () => setState(() {
                              _quantity = _quantity > 1 ? _quantity - 1 : 1;
                            }),
                        icon: const Icon(Icons.remove, color: Colors.pink),
                        padding: const EdgeInsets.all(4),
                      ),
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add, color: Colors.pink),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addToCart(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade300, Colors.pink.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Related Products
            Row(
              children: [
                Icon(
                  Icons.local_florist,
                  color: Colors.pink.shade400,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Related Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            relatedProducts.isNotEmpty
                ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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
                : Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_florist,
                        size: 60,
                        color: Colors.pink.shade200,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No related products found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

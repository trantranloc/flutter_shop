import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_shop/models/cart_item.dart';
import 'package:go_router/go_router.dart';
import '../services/cart_service.dart';
import '../widgets/card_item.dart'; // Giả sử đây là widget hiển thị từng item giỏ hàng

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _cartService.getCartItems();
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading cart items: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tải giỏ hàng: $e')));
    }
  }

  // Ví dụ về tính tổng tiền giỏ hàng (_totalAmount)
  double get _totalAmount {
    double total = 0;
    for (var item in _cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeItem(item);
      return;
    }

    setState(() {
      // Update in local state for immediate UI response
      final index = _cartItems.indexOf(item);
      if (index != -1) {
        _cartItems[index] = CartItem(
          id: item.id,
          name: item.name,
          price: item.price,
          images: item.images,
          product: item.product,
          quantity: newQuantity,
        );
      }
    });

    try {
      _cartService.updateCartItem(item.product.id, newQuantity);
    } catch (e) {
      print("Error updating quantity: $e");
      await _loadCartItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật số lượng: $e')),
      );
    }
  }

  Future<void> _removeItem(CartItem item) async {
    setState(() {
      _cartItems.remove(item);
    });

    try {
      _cartService.removeFromCart(item.product.id);
    } catch (e) {
      print("Error removing item: $e");
      await _loadCartItems();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể xóa sản phẩm: $e')));
    }
  }

  Future<void> _clearCart() async {
    setState(() {
      _cartItems = [];
    });

    try {
      _cartService.clearCart();
    } catch (e) {
      print("Error clearing cart: $e");
      await _loadCartItems();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể xóa giỏ hàng: $e')));
    }
  }

  // Check if user is logged in
  Future<bool> _isLoggedIn() async {
    final token = await _storage.read(key: 'accessToken');
    final userData = await _storage.read(key: 'user');
    return token != null && userData != null;
  }

  // Navigate to checkout or prompt login
  Future<void> _proceedToCheckout() async {
    if (await _isLoggedIn()) {
      GoRouter.of(context).go('/checkout');
    } else {
      // Show login dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Đăng nhập để tiếp tục'),
              content: Text('Bạn cần đăng nhập để tiến hành thanh toán.'),
              actions: [
                TextButton(
                  child: Text('Hủy'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('Đăng nhập'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    GoRouter.of(context).pushNamed('/login');
                  },
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.pink[50], // 🌸 Màu nền hồng nhẹ - matching HomeScreen
      appBar: AppBar(
        title: Text(
          "Cart",
          style: TextStyle(
            fontFamily: 'CrimsonText-Italic', // Font chữ có chân
            fontWeight: FontWeight.w200, // Chữ mỏng
            fontStyle: FontStyle.italic, // Chữ in nghiêng
          ),
        ),
        backgroundColor: Colors.pink, // 🌸 Màu AppBar - matching HomeScreen
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Xóa giỏ hàng?'),
                        content: Text(
                          'Bạn có chắc chắn muốn xóa tất cả sản phẩm trong giỏ hàng?',
                        ),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text('Delete All'),
                            onPressed: () {
                              _clearCart();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                );
              },
            ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.pink))
              : _cartItems.isEmpty
              ? _buildEmptyCart()
              : _buildCartList(),
      bottomNavigationBar: _cartItems.isEmpty ? null : _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.pink.withOpacity(0.5),
          ),
          SizedBox(height: 20),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 24,
              color: Colors.pink,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/product');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: CartItemCard(
            item: item,
            onUpdateQuantity:
                (newQuantity) => _updateQuantity(item, newQuantity),
            onRemove: () => _removeItem(item),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_totalAmount.toStringAsFixed(0)} ₫',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cartItems.isEmpty ? null : _proceedToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

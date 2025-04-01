import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  List<CartItem> cartItems = [];
  bool isLoading = true;
  final String userId = "userId";

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      isLoading = true;
    });

    try {
      final items = await _cartService.fetchCart(userId);
      setState(() {
        cartItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tải giỏ hàng: $e')));
    }
  }

  Future<void> _updateItemQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) return;

    setState(() {
      isLoading = true;
    });

    try {
      bool success = await _cartService.updateCartItemQuantity(
        item.id,
        newQuantity,
      );
      if (success) {
        // Update locally without needing to reload entire cart
        setState(() {
          int index = cartItems.indexWhere((element) => element.id == item.id);
          if (index != -1) {
            cartItems[index] = CartItem(
              id: item.id,
              name: item.name,
              price: item.price,
              quantity: newQuantity,
              imageUrl: item.imageUrl,
            );
          }
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể cập nhật số lượng')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeItem(String itemId) async {
    setState(() {
      isLoading = true;
    });

    try {
      bool success = await _cartService.removeCartItem(itemId);
      if (success) {
        setState(() {
          cartItems.removeWhere((item) => item.id == itemId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa sản phẩm khỏi giỏ hàng')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể xóa sản phẩm')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  double _calculateTotal() {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng'),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadCart)],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : cartItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Giỏ hàng trống', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Quay lại màn hình sản phẩm
                      },
                      child: Text('Tiếp tục mua sắm'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            leading: Image.network(
                              item.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Giá: \$${item.price.toStringAsFixed(2)}'),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        if (item.quantity > 1) {
                                          _updateItemQuantity(
                                            item,
                                            item.quantity - 1,
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_circle,
                                        color: Colors.green,
                                      ),
                                      onPressed: () {
                                        _updateItemQuantity(
                                          item,
                                          item.quantity + 1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(item.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng tiền:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${_calculateTotal().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Chức năng thanh toán đang được phát triển',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Thanh toán',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

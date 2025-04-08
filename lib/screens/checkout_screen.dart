import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_shop/models/cart_item.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../services/cart_service.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  _CheckOutScreenState createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final CartService _cartService = CartService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Map<String, dynamic>? _userData;
  List<CartItem> _cartItems = [];

  double get total => _cartItems.fold(
    0,
    (sum, item) => sum + item.product.price * item.quantity,
  );

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _notesController = TextEditingController();

  String country = 'Vietnam';
  String paymentMethod = 'cod';
  bool isSubmitting = false;
  String? errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCartItems();
  }

  Future<void> _loadUserData() async {
    try {
      final userString = await _storage.read(key: 'user');
      final tokenString = await _storage.read(key: 'accessToken');

      if (userString == null || tokenString == null) {
        // If user is not logged in, redirect to login screen
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vui lòng đăng nhập để thanh toán')),
          );
          context.go('/login');
        }
        return;
      }

      setState(() {
        _userData = json.decode(userString);
        _userData!['accessToken'] = tokenString;
      });

      // Pre-fill user information
      if (_userData != null) {
        final userName = _userData!['name'] ?? '';
        final nameParts = userName.split(' ');

        if (nameParts.isNotEmpty) {
          _lastNameController.text = nameParts.last;
          _firstNameController.text =
              nameParts.length > 1
                  ? nameParts.sublist(0, nameParts.length - 1).join(' ')
                  : '';
        }

        _emailController.text = _userData!['email'] ?? '';
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
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

      // If cart is empty, go back to cart screen
      if (items.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giỏ hàng trống, không thể thanh toán')),
        );
        context.go('/cart');
      }
    } catch (e) {
      print("Error loading cart items: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> handleSubmitOrder() async {
    if (!_formKey.currentState!.validate() || isSubmitting) return;

    print('Submitting order...');
    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    final userDetails = {
      'firstName': '${_firstNameController.text} ${_lastNameController.text}',
      'lastName': '${_firstNameController.text} ${_lastNameController.text}',
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': {
        'street': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zip': _zipController.text,
        'country': country,
      },
    };

    try {
      if (_userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dữ liệu người dùng không hợp lệ')),
        );
        return;
      }

      print('_userData: $_userData');
      print('_userData["_id"]: ${_userData?["_id"]}');

      await _cartService.submitOrder(
        user: _userData!,
        billingData: userDetails,
        paymentMethod: paymentMethod,
        notes: _notesController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt hàng thành công! Vui lòng kiểm tra email'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to home screen
      context.go('/home');
    } catch (e) {
      print("Error submitting order: $e");
      setState(() {
        errorMessage = 'Không thể đặt hàng: $e';
      });
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> handleVnpayPayment() async {
    setState(() => isSubmitting = true);

    try {
      // final paymentUrl = await _cartService.initiateVnpayPayment();

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Thanh toán VNPay'),
                content: Text(
                  'Chuyển hướng đến:(Vui lòng hoàn tất thanh toán)',
                  // 'Chuyển hướng đến: $paymentUrl\n(Vui lòng hoàn tất thanh toán)',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi khởi tạo VNPay: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thanh Toán'),
          elevation: 0,
          backgroundColor: Colors.pink.shade50,
        ),
        body: Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh Toán'),
        elevation: 0,
        backgroundColor: Colors.pink.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin sản phẩm
                _buildSectionTitle(context, 'Sản phẩm của bạn'),
                const SizedBox(height: 12),
                _buildCartItemsList(),

                // Thông tin cá nhân
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Thông Tin Cá Nhân'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: _inputDecoration('Họ'),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Vui lòng nhập họ' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: _inputDecoration('Tên'),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Vui lòng nhập tên' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) =>
                          !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)
                              ? 'Vui lòng nhập email hợp lệ'
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration('Số Điện Thoại'),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                ),

                // Địa chỉ giao hàng
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Địa Chỉ Giao Hàng'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: _inputDecoration('Địa Chỉ'),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: _inputDecoration('Thành Phố'),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Vui lòng nhập thành phố'
                                    : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        decoration: _inputDecoration('Tỉnh/Quận'),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Vui lòng nhập tỉnh/quận'
                                    : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _zipController,
                        decoration: _inputDecoration('Mã Zip'),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Vui lòng nhập mã zip' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: country,
                        decoration: _inputDecoration('Quốc Gia'),
                        onChanged: (value) => setState(() => country = value!),
                        items:
                            [
                                  'Vietnam',
                                  'Australia',
                                  'Canada',
                                  'China',
                                  'Morocco',
                                  'Saudi Arabia',
                                  'United Kingdom (UK)',
                                  'United States (US)',
                                ]
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        validator:
                            (value) =>
                                value == null ? 'Vui lòng chọn quốc gia' : null,
                      ),
                    ),
                  ],
                ),

                // Ghi chú đơn hàng
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Ghi Chú Đơn Hàng (Tùy Chọn)'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: _inputDecoration('Ghi chú về đơn hàng của bạn'),
                ),

                // Phương thức thanh toán
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Phương Thức Thanh Toán'),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        RadioListTile(
                          title: const Text('COD (Thanh toán khi nhận hàng)'),
                          value: 'cod',
                          groupValue: paymentMethod,
                          onChanged:
                              (value) => setState(() => paymentMethod = value!),
                          activeColor: Colors.pink.shade400,
                        ),
                        RadioListTile(
                          title: const Text('VNPay / Ngân hàng ATM'),
                          value: 'vnpay',
                          groupValue: paymentMethod,
                          onChanged: (value) {
                            setState(() => paymentMethod = value!);
                          },
                          activeColor: Colors.pink.shade400,
                        ),
                      ],
                    ),
                  ),
                ),

                // Tổng giỏ hàng
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng Giỏ Hàng:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${total.toStringAsFixed(0)} VND',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Nút đặt hàng
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      isSubmitting
                          ? null
                          : paymentMethod == 'vnpay'
                          ? handleVnpayPayment
                          : handleSubmitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade400,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            paymentMethod == 'vnpay'
                                ? 'Thanh toán VNPay'
                                : 'Đặt Hàng',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),

                // Thông báo lỗi
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var item in _cartItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.images[0],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.pink.shade100,
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.pink.shade300,
                              ),
                            ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Số lượng: ${item.quantity}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(item.product.price * item.quantity).toStringAsFixed(0)} ₫',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${item.product.price.toStringAsFixed(0)} ₫/cái',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (_cartItems.length > 1) Divider(height: 32, thickness: 1),
            if (_cartItems.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng (${_cartItems.length} sản phẩm):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${total.toStringAsFixed(0)} ₫',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo tiêu đề phần
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.pink.shade400,
      ),
    );
  }

  // Hàm tạo InputDecoration chung
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

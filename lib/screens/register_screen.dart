import 'package:flutter/material.dart';
import 'package:flutter_shop/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import '../styles/app_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  final RegisterLoginService _registerLoginService = RegisterLoginService();

  Future<void> _register() async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Kiểm tra lỗi nhập liệu
    setState(() {
      _emailError = email.isEmpty ? "Email không được để trống!" : null;
      _passwordError =
          password.isEmpty ? "Mật khẩu không được để trống!" : null;
      _confirmPasswordError =
          confirmPassword.isEmpty
              ? "Nhập lại mật khẩu không được để trống!"
              : null;
    });

    if (_emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    // Kiểm tra định dạng email
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      setState(() => _emailError = "Email không hợp lệ!");
      return;
    }

    // Kiểm tra độ dài & điều kiện mật khẩu
    if (password.length < 8 ||
        !RegExp(r'^(?=.*[A-Z])(?=.*\d).+$').hasMatch(password)) {
      setState(() {
        _passwordError = "Mật khẩu ít nhất 6 ký tự, chứa 1 số và 1 chữ in hoa!";
      });
      return;
    }

    // Kiểm tra mật khẩu nhập lại
    if (password != confirmPassword) {
      setState(() => _confirmPasswordError = "Mật khẩu không khớp!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _registerLoginService.registerUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      setState(() => _isLoading = false);
      final responseData = response.data;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng ký thành công!"),
            backgroundColor: Colors.pink,
          ),
        );
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['error'] ?? "Lỗi đăng ký!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lỗi kết nối đến server!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryPink = Colors.pink;
    final Color lightPink = Colors.pink[50]!;
    final Color darkPink = Colors.pink[800]!;

    return Scaffold(
      backgroundColor: lightPink,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Tạo tài khoản mới",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkPink,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _firstNameController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Họ',
                    prefixIcon: Icon(Icons.person, color: primaryPink),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryPink, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastNameController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Tên',
                    prefixIcon: Icon(Icons.person, color: primaryPink),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryPink, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: primaryPink),
                    errorText: _emailError,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryPink, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock, color: primaryPink),
                    errorText: _passwordError,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryPink, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Nhập lại mật khẩu',
                    prefixIcon: Icon(Icons.lock, color: primaryPink),
                    errorText: _confirmPasswordError,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryPink, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Đăng ký",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    GoRouter.of(context).go('/login');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryPink),
                    foregroundColor: primaryPink,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Đã có tài khoản?",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

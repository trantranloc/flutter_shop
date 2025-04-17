import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../styles/app_styles.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  final RegisterLoginService _authService = RegisterLoginService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validate email format
  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return "Email cannot be empty!";
    }
    if (email.length > 50) {
      return "Email is too long!";
    }
    if (email.contains(RegExp(r'\s'))) {
      return "Email cannot contain whitespace!";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return "Invalid email format!";
    }
    if (RegExp(r'^[0-9]').hasMatch(email)) {
      return "Email cannot start with a number!";
    }
    if(email.length < 5) {
      return "Email must be at least 5 characters long!";
    }

    return null;
  }

  // Validate password requirements
  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return "Password cannot be empty!";
    }
    if (password.length < 8) {
      return "Password must be at least 8 characters long!";
    }
    if (password.length > 128) {
      return "Password is too long!";
    }
    if (password.contains(RegExp(r'\s'))) {
      return "Password cannot contain whitespace!";
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return "Password must contain at least one uppercase letter!";
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return "Password must contain at least one number!";
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return "Password must contain at least one special character!";
    }
    return null;
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Kiểm tra lỗi nhập liệu
    setState(() {
      _emailError = _validateEmail(email);
      _passwordError = _validatePassword(password);
    });

    if (_emailError != null || _passwordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.loginUser(
        email: email,
        password: password,
      );

      setState(() => _isLoading = false);

      if (response != null) {
        // Kiểm tra nếu response là một Map (JSON) và có chứa mã lỗi
        if (response.containsKey('statusCode') &&
            response['statusCode'] == 401) {
          // Xử lý lỗi 401: Invalid email or password
          _showErrorSnackBar("Invalid email or password");
        } else if (response.containsKey('error')) {
          // Xử lý các lỗi khác từ server
          String errorMessage = response['error'];
          if (errorMessage.toLowerCase().contains('password') ||
              errorMessage.toLowerCase().contains('mật khẩu')) {
            _showErrorSnackBar("Mật khẩu không đúng!");
          } else if (errorMessage.toLowerCase().contains('email') ||
              errorMessage.toLowerCase().contains('user not found')) {
            _showErrorSnackBar("Email không tồn tại!");
          } else if (errorMessage == "Invalid email or password") {
            _showErrorSnackBar("Email hoặc mật khẩu không hợp lệ!");
          } else {
            _showErrorSnackBar(errorMessage);
          }
        } else {
          // Đăng nhập thành công
          _handleSuccessfulLogin(response);
        }
      } else {
        _showErrorSnackBar("Không nhận được phản hồi từ server!");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Lỗi kết nối đến server: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleSuccessfulLogin(Map<String, dynamic> response) {
    GoRouter.of(context).go('/home', extra: response);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đăng nhập thành công!"),
        backgroundColor: Colors.pink,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryPink = Colors.pink;
    final Color darkPink = Colors.pink[800]!;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg-auth.jpg'),
          fit: BoxFit.cover, // Tràn toàn màn hình
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Welcome Back!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkPink,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // TextField cho Email
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
                  // TextField cho Mật khẩu
                  TextField(
                    controller: _passwordController,
                    decoration: AppStyles.inputDecoration.copyWith(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: primaryPink),
                      errorText: _passwordError,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryPink, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  // Nút đăng nhập
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
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
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                  const SizedBox(height: 16),
                  // Nút chuyển sang trang đăng ký
                  OutlinedButton(
                    onPressed: () {
                      context.go('/register');
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
                      "Create an account",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Kiểm tra lỗi nhập liệu
    setState(() {
      _emailError = email.isEmpty ? "Email không được để trống!" : null;
      _passwordError =
          password.isEmpty ? "Mật khẩu không được để trống!" : null;
    });

    // Nếu có lỗi nhập liệu thì dừng lại
    if (_emailError != null || _passwordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.loginUser(
        email: email,
        password: password,
      );

      print("Phản hồi đăng nhập: $response");
      setState(() => _isLoading = false);

      // Kiểm tra phản hồi từ server
      if (response != null) {
        if (response.containsKey('error')) {
          // Xử lý lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? "Đăng nhập thất bại!"),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Đăng nhập thành công - Nên có thông tin người dùng trong response
          print("Thông tin user: $response");
          GoRouter.of(context).go('/home', extra: response);
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đăng nhập thành công!"),
              backgroundColor: Colors.pink,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Response là null
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không nhận được phản hồi từ server!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Lỗi khi đăng nhập: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi kết nối đến server: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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

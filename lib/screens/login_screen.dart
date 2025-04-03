import 'package:flutter/material.dart';
import 'package:flutter_shop/screens/home_screen.dart';
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

          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đăng nhập thành công!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Chuyển hướng tới trang chính sau khi hiển thị thông báo
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              // Kiểm tra widget có còn trong tree không
              try {
                // Sử dụng NavigatorState nếu có
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pushReplacementNamed('/home');
                } else {
                  // Sử dụng GoRouter nếu đã thiết lập
                  GoRouter.of(context).go('/');
                }
              } catch (e) {
                print("Lỗi khi chuyển hướng: $e");
                // Backup plan nếu các phương thức trên thất bại
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ), // Thay thế bằng trang chính của bạn
                  (route) => false,
                );
              }
            }
          });
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
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Chào mừng trở lại!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 32),
                // TextField cho Email
                TextField(
                  controller: _emailController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.green),
                    errorText: _emailError,
                  ),
                ),
                SizedBox(height: 16),
                // TextField cho Mật khẩu
                TextField(
                  controller: _passwordController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock, color: Colors.green),
                    errorText: _passwordError,
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                // Nút đăng nhập
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: AppStyles.greenButton,
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Đăng nhập"),
                ),
                SizedBox(height: 16),
                // Nút chuyển sang trang đăng ký
                OutlinedButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  style: AppStyles.outlinedGreenButton,
                  child: Text("Tạo tài khoản mới"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

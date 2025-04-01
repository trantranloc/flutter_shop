import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/app_styles.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../services/login_register_service.dart';

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

  // Hàm đăng nhập
  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Kiểm tra lỗi nhập liệu
    setState(() {
      _emailError = email.isEmpty ? "Email không được để trống!" : null;
      _passwordError = password.isEmpty ? "Mật khẩu không được để trống!" : null;
    });

    // Nếu có lỗi nhập liệu thì dừng lại
    if (_emailError != null || _passwordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.loginUser(email: email, password: password);
      setState(() => _isLoading = false);

      // Kiểm tra kết quả từ API
      if (response.statusCode == 200 && response.data['token'] != null) {
        // Lưu token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data['token']); // Lưu token

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng nhập thành công!"), backgroundColor: Colors.green),
        );

        // Chuyển hướng tới trang chính sau khi đăng nhập thành công
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['error'] ?? "Sai tài khoản hoặc mật khẩu!"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối đến server!"), backgroundColor: Colors.red),
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
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Đăng nhập"),
                ),
                SizedBox(height: 16),
                // Nút chuyển sang trang đăng ký
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
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

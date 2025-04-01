import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_shop/screens/login_screen.dart';
import 'package:flutter_shop/services/login_register_service.dart';
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
      _passwordError = password.isEmpty ? "Mật khẩu không được để trống!" : null;
      _confirmPasswordError = confirmPassword.isEmpty ? "Nhập lại mật khẩu không được để trống!" : null;
    });

    if (_emailError != null || _passwordError != null || _confirmPasswordError != null) {
      return;
    }

    // Kiểm tra định dạng email
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      setState(() => _emailError = "Email không hợp lệ!");
      return;
    }

    // Kiểm tra độ dài & điều kiện mật khẩu
    if (password.length < 8 || !RegExp(r'^(?=.*[A-Z])(?=.*\d).+$').hasMatch(password)) {
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
          SnackBar(content: Text("Đăng ký thành công!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['error'] ?? "Lỗi đăng ký!"), backgroundColor: Colors.red),
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
                  "Register Your Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 32),
                TextField(
                  controller: _firstNameController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _lastNameController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                    errorText: _emailError,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    errorText: _passwordError,
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: AppStyles.inputDecoration.copyWith(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    errorText: _confirmPasswordError,
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: AppStyles.redButton,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Create Account"),
                ),
                SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()), // Chuyển hướng tới trang đăng nhập
                    );
                  },
                  style: AppStyles.outlinedGreenButton,
                  child: Text("Already an Account ?"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

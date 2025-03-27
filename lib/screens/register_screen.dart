import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../styles/app_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

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
      return; // Nếu có lỗi, dừng quá trình đăng ký
    }

    // Kiểm tra định dạng email
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email)) {
      setState(() => _emailError = "Email phải có đuôi @gmail.com!");
      return;
    }

    // Kiểm tra độ dài & điều kiện mật khẩu
    if (password.length < 3 ||
        !RegExp(r'^(?=.*[A-Z])(?=.*\d).+$').hasMatch(password)) {
      setState(() {
        _passwordError = "Mật khẩu ít nhất 3 ký tự, chứa 1 số và 1 chữ in hoa!";
      });
      return;
    }

    // Kiểm tra mật khẩu nhập lại
    if (password != confirmPassword) {
      setState(() => _confirmPasswordError = "Mật khẩu không khớp!");
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('https://676bfddfbc36a202bb866149.mockapi.io/api/v1/users'),
      body: {'email': email, 'password': password},
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng ký thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đăng ký!"), backgroundColor: Colors.red),
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
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: AppStyles.inputDecoration.copyWith(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.green),
                  errorText: _emailError,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: AppStyles.inputDecoration.copyWith(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock, color: Colors.green),
                  errorText: _passwordError,
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: AppStyles.inputDecoration.copyWith(
                  labelText: 'Nhập lại mật khẩu',
                  prefixIcon: Icon(Icons.lock, color: Colors.green),
                  errorText: _confirmPasswordError,
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: AppStyles.greenButton,
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Đăng ký"),
              ),
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: AppStyles.outlinedGreenButton,
                child: Text("Quay lại đăng nhập"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

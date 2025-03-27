import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../styles/app_styles.dart';
import 'register_screen.dart';
import 'dart:convert';
import 'home_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

Future<void> _login() async {
  setState(() => _isLoading = true);

  final response = await http.get(
    Uri.parse('https://676bfddfbc36a202bb866149.mockapi.io/api/v1/users'),
  );

  setState(() => _isLoading = false);

  if (response.statusCode == 200) {
    List<dynamic> users = jsonDecode(response.body);

    final user = users.firstWhere(
      (u) =>
          u['email'] == _emailController.text &&
          u['password'] == _passwordController.text,
      orElse: () => {}, // Trả về Map rỗng thay vì null
    );

    if (user.isNotEmpty) { // Kiểm tra nếu user tồn tại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng nhập thành công! Xin chào, ${user['username']}"),
          backgroundColor: Colors.green,
        ),
      );

      // Chuyển hướng sau khi hiển thị thông báo
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sai tài khoản hoặc mật khẩu!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Lỗi kết nối đến server!"),
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
              TextField(
                controller: _emailController,
                decoration: AppStyles.inputDecoration.copyWith(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.green),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: AppStyles.inputDecoration.copyWith(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock, color: Colors.green),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: AppStyles.greenButton,
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Đăng nhập"),
              ),
              SizedBox(height: 16),
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
    );
  }
}

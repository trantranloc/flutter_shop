import 'package:flutter/material.dart';
import 'package:flutter_shop/screens/register_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_screen.dart'; // Import màn hình đăng nhập

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true; // Trạng thái loading

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080//profile'));

      if (response.statusCode == 200) {
        setState(() {
          user = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Delay điều hướng để tránh lỗi context chưa sẵn sàng
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          );
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegisterScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : user == null
              ? Center(child: Text("Không thể tải thông tin"))
              : Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${user!['name']}'),
                    SizedBox(height: 16),
                    Text('Email: ${user!['email']}'),
                  ],
                ),
              ),
    );
  }
}

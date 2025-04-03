import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // Lấy thông tin người dùng
  Future<void> _fetchUserInfo() async {
    try {
      // Đọc accessToken từ Secure Storage
      String? token = await _storage.read(key: 'accessToken');
      if (token == null) {
        context.go('/login');
        return;
      }

      // Đọc thông tin user từ Secure Storage
      String? userInfoString = await _storage.read(key: 'user');

      if (userInfoString == null || userInfoString.isEmpty) {
        print('Dữ liệu người dùng trống');
        setState(() {
          isLoading = false;
        });
        return;
      }

      print('Dữ liệu nhận được: $userInfoString');

      try {
        // Chuyển đổi chuỗi JSON thành đối tượng Map
        Map<String, dynamic> userInfo = json.decode(userInfoString);
        setState(() {
          user = userInfo;
          isLoading = false;
        });
      } catch (e) {
        print("Lỗi khi phân tích JSON: $e");
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Lỗi khi lấy thông tin người dùng: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink.shade300, // Light pink theme
      ),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator(color: Colors.pink.shade300)
                : user == null
                ? _buildGuestProfile(context)
                : _buildUserProfile(),
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Text(
          "Welcome to our flower shop!",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            context.push("/login");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade300,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            "LOGIN",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            'Name: ${user?['name'] ?? ''}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Email: ${user?['email'] ?? 'Chưa có email'}',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 20),
          _buildUserOptions(),
        ],
      ),
    );
  }

  Widget _buildUserOptions() {
    return Column(
      children: [
        _buildMenuItem(Icons.shopping_cart, "My Cart", '/cart'),
        _buildMenuItem(Icons.person, "Personal Information", '/profile'),
        _buildMenuItem(Icons.settings, "Settings", '/settings'),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink.shade300),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: () {
        context.go(route); // Điều hướng đến route tương ứng
      },
    );
  }
}

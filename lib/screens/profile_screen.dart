import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart'; // Import RegisterLoginService

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final RegisterLoginService _authService =
      RegisterLoginService(); // Khởi tạo service

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // Lấy thông tin người dùng
  Future<void> _fetchUserInfo() async {
    try {
      String? token = await _storage.read(key: 'accessToken');
      if (token == null) {
        context.go('/login');
        return;
      }

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

  // Hàm xử lý đăng xuất
  Future<void> _logout() async {
    try {
      await _authService.logoutUser(); // Gọi hàm logout từ RegisterLoginService
      if (mounted) {
        context.go('/login'); // Điều hướng về màn hình đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đăng xuất thành công!"),
            backgroundColor: Colors.pink,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi khi đăng xuất: $e"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink.shade300,
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
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              user?['avatar'] ?? 'https://example.com/default_avatar.png',
            ),
            child:
                user?['avatar'] == null
                    ? Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
          ),
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
        _buildMenuItem(Icons.receipt, "My Orders", '/orders'),
        _buildMenuItem(Icons.settings, "Settings", '/settings'),
        _buildMenuItem(
          Icons.logout,
          "Logout",
          null,
          onTap: _logout,
        ), // Thêm nút Logout
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String? route, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink.shade300),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap ?? (route != null ? () => context.go(route) : null),
    );
  }
}

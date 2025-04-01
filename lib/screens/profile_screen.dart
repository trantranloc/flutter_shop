import 'package:flutter/material.dart';
import 'package:flutter_shop/screens/register_screen.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart'; // Import GoRouter

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/profile'),
      );

      if (response.statusCode == 200) {
        setState(() {
          user = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Điều hướng đến RegisterScreen nếu không có profile
        context.go('/register');
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => isLoading = false);
      // Điều hướng đến RegisterScreen trong trường hợp lỗi
      context.go('/register');
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
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/default_user.png'),
        ),
        SizedBox(height: 20),
        Text(
          "Welcome to our flower shop!",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // Điều hướng tới màn hình đăng nhập và sau khi quay lại sẽ refresh profile
            context.push("/login").then((_) {
              _fetchProfile();
            });
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
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              user!['avatarUrl'] ?? 'https://via.placeholder.com/150',
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Name: ${user!['name']}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Email: ${user!['email']}',
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'dart:convert';

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
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => isLoading = false);
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
                ? _buildGuestProfile()
                : _buildUserProfile(),
      ),
    );
  }

  Widget _buildGuestProfile() {
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade300,
            padding: EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 15,
            ), // Bigger button
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
        _buildMenuItem(Icons.shopping_cart, "My Cart"),
        _buildMenuItem(Icons.person, "Personal Information"),
        _buildMenuItem(Icons.settings, "Settings"),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink.shade300),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: () {
        // Navigation function if needed
      },
    );
  }
}

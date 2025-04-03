import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<String> _routes = ['/home', '/product', '/cart', '/profile'];

  // Khai báo GlobalKey cho ScaffoldState
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    GoRouter.of(context).go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _scaffoldKey,
      // appBar: AppBar(
      //   title: Text('Pink Blossom Shop'),
      //   backgroundColor: Colors.pink.shade300,
      //   leading: IconButton(
      //     icon: Icon(Icons.menu), // Biểu tượng ba thanh gạch
      //     onPressed: () {
      //       // Mở Drawer khi nhấn vào biểu tượng menu
      //       _scaffoldKey.currentState?.openDrawer();
      //     },
      //   ),
      // ),
      body: widget.child, // Hiển thị nội dung của từng màn hình
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Products'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pink.shade700,
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       DrawerHeader(
      //         decoration: BoxDecoration(color: Colors.pink.shade300),
      //         child: Text(
      //           'Pink Blossom Shop',
      //           style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 24,
      //             fontWeight: FontWeight.bold,
      //           ),
      //         ),
      //       ),
      //       // Các mục trong Drawer
      //       ListTile(
      //         leading: Icon(Icons.home),
      //         title: Text('Home'),
      //         onTap: () {
      //           // Điều hướng đến màn hình Home
      //           Navigator.pushNamed(context, '/home');
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.shopping_cart),
      //         title: Text('Cart'),
      //         onTap: () {
      //           // Điều hướng đến màn hình Cart
      //           GoRouter.of(context).go('/cart');
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.account_circle),
      //         title: Text('Profile'),
      //         onTap: () {
      //           // Điều hướng đến màn hình Profile
      //           Navigator.pushNamed(context, '/profile');
      //         },
      //       ),
      //       // Thêm các mục khác nếu cần
      //     ],
      //   ),
      // ),
    );
  }
}

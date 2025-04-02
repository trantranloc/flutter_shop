import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// Màn hình chính
import 'screens/home_screen.dart';
import 'screens/product_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart'; // Thêm màn hình Login
import 'screens/register_screen.dart'; // Thêm màn hình Register

void main() {
  setUrlStrategy(PathUrlStrategy()); 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pink.shade300, // Light pink theme
        scaffoldBackgroundColor: Colors.pink.shade50, // Soft background
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.pink.shade700,
          unselectedItemColor: Colors.grey[500],
          backgroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade300,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      routerConfig: _router, // Cấu hình router tại đây
    );
  }

  // Cấu hình GoRouter
  final GoRouter _router = GoRouter(
    initialLocation: '/', // Đặt màn hình mặc định khi khởi động
    routes: [
      // Đường dẫn chính
      GoRoute(path: '/', builder: (context, state) => MainScreen()),
      // Đường dẫn cho các màn hình khác
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
      // Các route cho các màn hình khác
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/product', builder: (context, state) => ProductScreen()),
      GoRoute(path: '/cart', builder: (context, state) => CartScreen()),
      GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
    ],
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ProductScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.store),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.pink.shade700,
            unselectedItemColor: Colors.grey[500],
            showUnselectedLabels: true,
            backgroundColor: Colors.white,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            elevation: 10,
          ),
        ),
      ),
    );
  }
}

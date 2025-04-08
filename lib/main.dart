import 'package:flutter/material.dart';
import 'package:flutter_shop/screens/checkout_screen.dart';
import 'package:flutter_shop/screens/login_screen.dart';
import 'package:flutter_shop/screens/register_screen.dart';
import 'package:flutter_shop/screens/order_list_screen.dart';
import 'package:flutter_shop/screens/order_detail_screen.dart';
import 'package:go_router/go_router.dart';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'main_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  // setUrlStrategy(PathUrlStrategy());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/home',
    routes: [
      // Route chính với ShellRoute để giữ lại BottomNavigationBar
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
          GoRoute(
            path: '/product',
            builder: (context, state) => ProductScreen(),
          ),
          GoRoute(path: '/cart', builder: (context, state) => CartScreen()),
          GoRoute(
            path: '/checkout',
            builder: (context, state) => CheckOutScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrderListScreen(),
          ),
          GoRoute(
            path: '/order/:orderId',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return OrderDetailScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => ProfileScreen(),
          ),
        ],
      ),
      // Các route riêng không có Navigation Bar
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pink.shade300,
        scaffoldBackgroundColor: Colors.pink.shade50,
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
      routerConfig: _router,
    );
  }
}

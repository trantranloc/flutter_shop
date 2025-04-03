import 'package:flutter/material.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ảnh nền lấy từ thư mục assets
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            "assets/images/banner.jpg", 
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        // Chữ và nút Shop Now
        Positioned(
          top: 60,
          child: Column(
            children: [
              Text(
                "Perfect Bunch",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                ),
              ),
              Text(
                "For Every Occasion",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black45)],
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Điều hướng đến trang sản phẩm
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text("Shop Now"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

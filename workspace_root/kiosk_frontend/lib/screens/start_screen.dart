// lib/screens/start_screen.dart
import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Image.network(
                  'http://localhost:3006/images/start_banner.jpg',  // 백엔드 static 경로
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Icon(Icons.broken_image),
                )
              ),
            ),
          ),
          Container(
            color: Colors.indigo,
            padding: EdgeInsets.symmetric(vertical: 20),
            width: double.infinity,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/menu');
                },
                child: Text('시작하기', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
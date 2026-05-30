// lib/screens/payment_screen.dart

import 'package:flutter/material.dart';
// ReceiptScreen을 import 해야 합니다.
import 'receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  // 주문 ID를 받아오기 위해 orderId 필드를 선언
  final int orderId;
  const PaymentScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // 결제 처리 상태: true면 처리 중, false면 완료
  bool _processing = true;

  @override
  void initState() {
    super.initState();
    //3초 후에 결제 처리가 완료되었다고 가정하고 상태 변경
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; // 위젯이 아직 화면에 남아있을 때만 setState 호출
      setState(() => _processing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제'),
        backgroundColor: Colors.indigo, // 앱바 색상을 인디고로 설정
      ),
      body: Center(
        // _processing 값에 따라 다른 위젯을 표시
        child: _processing
        // 결제 중일 때 보여줄 위젯
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),       // 원형 인디케이터
            SizedBox(height: 16),
            Text('결제 중입니다!', style: TextStyle(fontSize: 18)),
          ],
        )
        // 결제 완료 후 보여줄 위젯
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 완료 아이콘
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text('결제 완료!', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),

            // 영수증 화면으로 이동하는 버튼
            ElevatedButton(
              onPressed: () {
                // ReceiptScreen으로 네비게이트할 때, orderId를 함께 전달
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReceiptScreen(
                      orderId: widget.orderId,
                    ),
                  ),
                );
              },
              child: const Text('영수증 출력'),
            ),

            const SizedBox(height: 12),
            // 주문번호를 다이얼로그로 보여주는 버튼
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('주문번호'),
                    content: Text('주문번호: ${widget.orderId}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('확인'),
                      )
                    ],
                  ),
                );
              },
              child: const Text('주문번호 출력'),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/receipt_screen.dart

import 'package:flutter/material.dart';
// 날짜/시간 포맷을 위한 intl 패키지
import 'package:intl/intl.dart';
// 서버 통신 로직을 담은 서비스 클래스
import '../services/api_service.dart';
// CartItem 모델은 여기서 사용하지 않지만, 주문 내역과 매핑할 때 필요할 수 있음.
import '../models/cart_item.dart';

class ReceiptScreen extends StatefulWidget {
  // 주문 ID를 생성자에서 받아서 사용.
  final int orderId;
  const ReceiptScreen({ Key? key, required this.orderId }) : super(key: key);

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool _loading = true;   // 데이터 로딩 상태
  String? _error;   // 오류 메시지 저장
  // 서버에서 받아온 주문 상세 데이터
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    // 화면이 생성되면 바로 주문 상세를 조회합니다.
    _fetchDetail();
  }

  // 서버에서 주문 상세를 가져오는 비동기 함수
  Future<void> _fetchDetail() async {
    try {
      // ApiService의 getOrderDetail을 호출해 주문 상세 데이터를 받아옴.
      final data = await ApiService().getOrderDetail(widget.orderId);
      setState(() {
        _detail = data; // 받아온 데이터를 _detail에 저장
      });
    } catch (e) {
      setState(() {
        _error = e.toString(); // 오류가 발생하면 _error에 메시지를 저장
      });
    } finally {
      // 위젯이 여전히 화면에 남아있으면 로딩 완료 상태로 변경
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1) 로딩 중일 때: 프로그레스 인디케이터만 표시
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('영수증')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 2) 에러가 발생했을 때: 에러 메시지 표시
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('영수증')),
        body: Center(child: Text('에러: $_error')),
      );
    }

    // 3) 정상적으로 데이터가 로드된 경우
    // _detail은 {'header': {...}, 'items': [...] } 형태로 가정
    final header = _detail!['header'] as Map<String, dynamic>;  // 주문 헤더 정보
    final items  = _detail!['items']  as List<dynamic>;         // 주문 내역 리스트
    // DateFormat을 사용해 문자열을 원하는 형식으로 변환 가능
    final df     = DateFormat('yyyy-MM-dd HH:mm:ss');

    // 총합 계산: 각 아이템의 가격 * 수량 합산
    int total = 0;
    for (var it in items) {
      total += (it['price'] as int) * (it['quantity'] as int);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('영수증'),
        backgroundColor: Colors.indigo, // 앱바 색상
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 주문 번호 표시
            Text(
              '주문번호: ${header['id']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // 주문 시간 표시: 문자열을 DateTime으로 파싱 후 포맷 적용
            Text(
              '주문 시간: ${df.format(DateTime.parse(header['order_time']))}',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 24),

            // 주문 내역 제목
            const Text(
              '주문 내역:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 메뉴 항목 리스트를 map()과 toList()로 위젯 리스트로 변환
            ...items.map((it) {
              // 각 아이템의 소계(subtotal) 계산
              final sub = (it['price'] as int) * (it['quantity'] as int);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 메뉴 이름과 수량 표시
                    Text('${it['name']} x${it['quantity']}'),
                    // 개별 아이템 가격 표시
                    Text('${it['price']}원'),
                    // 소계(가격 * 수량) 표시
                    Text('소계 ${sub}원'),
                  ],
                ),
              );
            }).toList(),

            const Divider(height: 32),

            // 총 결제 금액 표시 (우측 정렬)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 결제 금액:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '${total}원',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Spacer(), // 남은 공간을 밀어 다음 위젯을 화면 하단에 붙임

            // 영수증 인쇄 버튼 (실제 프린터 로직은 구현 필요)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 실제 프린터 기능이 있다면 여기에 연결
                },
                child: const Text('영수증 인쇄'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

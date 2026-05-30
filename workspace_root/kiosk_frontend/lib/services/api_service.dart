// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';
import '../models/cart_item.dart';

class ApiService {
  //Web, Windows, Mac, Linux 모두 localhost:3006 으로
  static const _baseUrl = 'http://localhost:3006/api';

  // Android 에뮬레이터 (Android only)
  // static const _baseUrl = 'http://10.0.2.2:3006/api';

  // 실기기에서는 PC LAN IP를 쓰되, 방화벽·바인딩을 열어야 함.
  // static const _baseUrl = 'http://192.168.0.10:3006/api';

  //http 요청에 사용할 client. 테스트용으로 주입 가능
  final http.Client _client;

  //생성자: 외부에서 client를 주입하지 않으면 기본 http.Client()를 사용
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// 메뉴 목록 가져오기 (선택적으로 restaurantId를 쿼리 파라미터로 넘길 수 있음)
  Future<List<MenuItem>> fetchMenu({int? restaurantId}) async {
    // 쿼리 파라미터로 restaurantId가 들어오면 ?restaurantId=값 을 붙입니다.
    final uri = Uri.parse('$_baseUrl/menu').replace(
      queryParameters: restaurantId != null
          ? {'restaurantId': restaurantId.toString()}
          : null,
    );

    //GET 요청 전송
    final resp = await _client.get(uri);
    if (resp.statusCode != 200) {   //상태 코드가 200이 아니면 예외를 던짐
      throw Exception('메뉴 로드 실패: \${resp.statusCode}');
    }
    //응답 본문을 JSON 파싱 (List 형태)
    final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;

    //JSON 배열을 MenuItem 객체 리스트로 변환
    return data
        .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 주문 전송
  /// { 'success':true, 'orderId':123 } 을 리턴하도록 수정
  Future<Map<String, dynamic>> placeOrder(List<CartItem> items) async {
    final uri = Uri.parse('$_baseUrl/order');
    // CartItem의 toJson()을 이용해 [{ 'menu_id': ..., 'qty': ... }, ...] 형태로 변환
    final body = jsonEncode({ 'items': items.map((e) => e.toJson()).toList()});
    final resp = await _client.post(    // POST 요청 전송: JSON 헤더 설정 필수
      uri,
      headers: { 'Content-Type': 'application/json'},
      body: body,
    );
    if (resp.statusCode != 200) {
      throw Exception('주문 실패: ${resp.statusCode}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// 주문 상세 조회
  /// GET /order/{orderId} 엔드포인트 호출
  Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    final uri = Uri.parse('$_baseUrl/order/$orderId');
    final resp = await _client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('주문 상세 로드 실패: ${resp.statusCode}');
    }
    // JSON 본문을 Map으로 변환하여 반환
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

}

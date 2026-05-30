// lib/models/cart_item.dart
class CartItem {    //장바구니에 담을 아이템 하나를 나타내는 모델 클래스
  final int id;   //메뉴 고유 ID (서버에 주문 보낼 때 사용)
  final String name;   // 메뉴 이름 UI 표시
  final int price;    // 메뉴 가격
  int quantity;   //선택된 수량: 기본값 1개

  CartItem({    //생성자: Id, name, price 필수 quantity는 1로 초기화
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  //서버에 JSON 형태로 주문을 보낼 떄 사용하는 메소드
  Map<String, dynamic> toJson() => {
    'menu_id': id,    //서버 API에서 요구하는 필드명: 'menu_id'에 id 값을 할당
    'qty': quantity,    //'qty'에 현재 수량 값을 할당함
  };
}

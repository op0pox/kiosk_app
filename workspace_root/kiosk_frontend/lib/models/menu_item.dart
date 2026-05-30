// lib/models/menu_item.dart

//서버에서 받아온 메뉴 데이터를 앱 내에서 사용하기 위한 모델 클래스
class MenuItem {
  final int id;   //메뉴의 고유 ID (서버 DB에서 저장된 값)
  final String name;    // 메뉴 이름(UI에 표현할 떄 사용)
  final int price;    //메뉴 가격(UI에 표시, 합계를 계산할 때 사용)
  final String imageUrl;    // (Image.network에 전달하여 이미지 불러옴)

  MenuItem({    //생성자: 모든 필드를 필수(required)로 받아서 초기화
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  //JSON 데이터를 MenuItem 객체로 변환하기 위한 팩토리 생성자
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as int,    //서버 JSON의 id 필드를 정수로 캐스팅해 name에 할당
      name: json['name'] as String,   //name 필드를 문자열로 캐스팅하여 name에 할당
      price: json['price'] as int,    //price 필드를 정수로 하여 price에 할당
      imageUrl: json['image_url'] as String,    //image_url 필드를 imageUrl에 할당
    );
  }
}

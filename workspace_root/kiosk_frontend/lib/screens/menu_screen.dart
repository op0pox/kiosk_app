// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';

import '../widgets/menu_card.dart';   //메뉴 카드 위젯 가져옴
import '../services/api_service.dart';    //API 호출 로직을 담은 서비스 클래스
import '../models/menu_item.dart';    // 메뉴 아이템
import '../models/cart_item.dart';    //장바구니 아이템
import 'payment_screen.dart';   //결제 화면으로 이동할 때 사용함


//StatefulWidget: 메뉴 데이터 불러오고, 장바구니 상태 관리를 위해 state가 필요
class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItem> menuItems = [];    //서버에서 받아올 메뉴 리스트
  bool _isLoading = true;   //로딩 상태 여부
  String? _error;   //에러 메세지 저장
  List<CartItem> cartItems = [];    //장바구니에 담긴 아이템

  // UI 카테고리 라벨 (식당 이름)
  static const List<String> categories = [
    '상하이', '한성면옥', '전주한식', '돈이돈까스',
  ];
  // DB의 restaurant_id 매핑 : categories 리스트와 매칭되는 DB의 restaurant_id 값
  static const List<int> restaurantIds = [1, 2, 3, 4];

  int _selectedCategory = 0;    //현재 선택된 카테고리 인덱스 (초기값: 0 => '상하이')

  @override
  void initState() {
    super.initState();
    _loadMenu();    //위젯이 생성된 직후 메뉴 데이터를 불러옴.
  }

  Future<void> _loadMenu() async {    //메뉴 데이터를 서버에서 가져오는 비동기 함수
    setState(() {
      _isLoading = true;    //로딩 시작
      _error = null;    //이전 에러 초기화 함
    });
    try {
      // 선택된 카테고리에 해당하는 restaurantId를 넘겨서 메뉴 조회(메뉴 목록 요청)
      final items = await ApiService().fetchMenu(
        restaurantId: restaurantIds[_selectedCategory],
      );
      setState(() {
        menuItems = items;    //받아온 메뉴 데이터를 화면에 반영 시킴
      });
    } catch (e) {
      setState(() {
        _error = e.toString();    //에러 메시지 저장
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;   //로딩 완료
        });
      }
    }
  }

  //카테고리 버튼을 눌렀을 경우에 호출되는 메소드
  void _selectCategory(int idx) {
    if (_selectedCategory == idx) return;     //이미 선택된 카테고리면 아무 작업도 하지 않게 함
    setState(() {
      _selectedCategory = idx;    //선택 값을 업데이트함
    });
    _loadMenu();    //새로운 카테고리로 메뉴를 다시 불러옴
  }

  //장바구니의 아이템 수량을 증가
  void _addQuantity(int idx) {
    setState(() {
      cartItems[idx].quantity++;
    });
  }


  //장바구니의 아이템 수량 감소 (최대 1개)
  void _removeQuantity(int idx) {
    setState(() {
      if (cartItems[idx].quantity > 1) {
        cartItems[idx].quantity--;
      }
    });
  }

  //장바구니에서 아이템 삭제
  void _removeItem(int idx) {
    setState(() {
      cartItems.removeAt(idx);
    });
  }

  // 장바구니에 담긴 전체 아이템 개수(수량 합계)
  int get totalCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  //장바구니에 담긴 전체 가격 (price * quantity)
  int get totalPrice =>
      cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  //주문을 서버에 전송 후 결제 화면으로 이동
  Future<void> _placeOrder() async {
    if (cartItems.isEmpty) return;
    try {
      final result = await ApiService().placeOrder(cartItems);    //서버에 주문 요청
      final orderId = result['orderId'] as int;
      // 주문 성공 시 결제 화면으로 이동
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(orderId: orderId),
        ),
      );
      // 카트 비우기 (결제 화면으로 넘어간 뒤에 장바구리르 초기화 함
      setState(() => cartItems.clear());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(   //주문 실패하면 스낵바로 알려줌)
        SnackBar(content: Text('주문 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(   //앱 상단 바
        title: const Text('메뉴'),    //앱 상단 바에 '메뉴'
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // 카테고리 버튼 바 (가로로 스크롤 가능하게 함)
          Container(
            width: double.infinity,
            color: Colors.indigo,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(categories.length, (i) {
                    final isSelected = i == _selectedCategory;    //현재 버튼이 선택된 상태인지 확인
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Colors.white    //선택된 카테고리(가게 버튼) 배경 흰색
                              : Colors.transparent,   //선택되지 않으면 투명함
                          foregroundColor: isSelected
                              ? Colors.indigo   //선택된 텍스트 색: 인디고
                              : Colors.white,   // 나머지: 흰색
                          elevation: 0,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => _selectCategory(i),
                        child: Text(categories[i]),   //카테고리 라벨 표시
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // 메뉴 목록 영역 (그리드) / 로딩 / 에러 처리
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())    //로딩 중이면 원형으로 표시 (프로그레스 바)
                  : _error != null
                  ? Center(child: Text('에러 발생: $_error'))   //에러 발생 시 텍스트로 에러 메시지 표시
                  : GridView.builder(     //정상적으로 메뉴 데이터를 받아왔을 때
                    itemCount: menuItems.length,
                    gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (_, i) {
                        final item = menuItems[i];
                        return MenuCard(
                          title: item.name,
                          price: item.price,
                          imageUrl: item.imageUrl,
                          onTap: () {   //메뉴 카드를 눌렀을 때 장바구니에 담기는 로직
                            setState(() {
                              final idx = cartItems.indexWhere(
                                      (ci) => ci.id == item.id);
                              if (idx >= 0) {   // 이미 장바구니에 있다면
                                cartItems[idx].quantity++;    //수량만 증가
                              } else {    //새로 담는 메뉴라면
                                cartItems.add(CartItem(   //cartitem 생성해서 추가함
                                  id: item.id,
                                  name: item.name,
                                  price: item.price,
                                  quantity: 1,
                                ));
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),

          // 장바구니 패널 (하단에 고정 시킴)
          Container(
            color: Colors.grey[100],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 장바구니 제목
                Container(
                  width: double.infinity,
                  color: Colors.indigo[50],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: const Text(
                    '장바구니',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                // 장바구니 아이템 리스트
                ListView.separated(
                  itemCount: cartItems.length,
                  shrinkWrap: true,   // ListView 가 필요한 만큼만 크기를 잡음
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, idx) {
                    final ci = cartItems[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(ci.name)),   //메뉴 이름
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _removeQuantity(idx),
                          ),
                          Text('${ci.quantity}'),   //현재 수량 표시
                          IconButton(   //수량 증가 버튼
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _addQuantity(idx),
                          ),
                          IconButton(   //아이템 삭제 버튼
                            icon: const Icon(Icons.close),
                            onPressed: () => _removeItem(idx),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),   // 합계 & 결제 버튼 영역
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '총 $totalCount 개 · ${totalPrice}원',   //총 개수 및 가격
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(   //결제하기 버튼: _placeOrder() 호출
                        onPressed: _placeOrder,
                        child: const Text('결제하기'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

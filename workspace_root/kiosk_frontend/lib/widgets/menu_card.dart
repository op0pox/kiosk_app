// lib/widgets/menu_card.dart

import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {    //메뉴 이름, 가격, 이미지 경로, 탭 콜백을 생성자로 받음.
  final String title;
  final int price;
  final String imageUrl;
  final VoidCallback onTap;

  const MenuCard({
    Key? key,
    required this.title,    //메뉴 명
    required this.price,    //메뉴 가격
    required this.imageUrl,   //이미지 파일명(경로)
    required this.onTap,    //메뉴 카드를 눌렀을 실행할 콜백
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,   //카드 전체를 탭할 수 있게 하고, 탭 시 넘겨 받은 onTap 함수를 실행함
      child: Card(
        shape:    //테두리 둥근 모서리 12
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,   //그림자 깊이 2
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(    //이미지 영역: 위쪽 반원 테두리를 ClipRRect로 잘라냄
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(   //백엔드 서버의 static 이미지 경로 사용
                'http://localhost:3006/images/$imageUrl',
                height: 150,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, chunk) {   //이미지 로딩 중 표시할 위젯 정의
                  if (chunk == null) return child;
                  return Container(   //로딩 중일 때, 높이 100짜리 회색 배경 + 프로그레스 인디케이터 표시
                    height: 100,
                    color: Colors.grey[200],
                    child:
                    const Center(child: CircularProgressIndicator()),
                  );
                },

                //이미지 로드 실패시 아이콘으로 대체
                errorBuilder: (_, __, ___) => Container(
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 15),    //이미지와 텍스트 사이 여백


            //메뉴 제목 및 가격을 보여주는 텍스트 부분
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,    //메뉴 제목 텍스트: 중앙 정렬, 검정색
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),    //제목과 가격 사이 여백
                  Text(   //메뉴 가격 텍스트: 중앙정렬, 회색
                    '$price원',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),    //아래 여백 (카드 하단과 텍스트 사이)
          ],
        ),
      ),
    );
  }
}

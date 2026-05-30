// lib/main.dart
import 'package:flutter/material.dart';   //플루터의 기본 라이브러리 가져오기
import 'screens/start_screen.dart';   //앱 내에서 사용한 화면 가져오기
import 'screens/menu_screen.dart';


void main() {
  runApp(KioskApp());   //플루터 엔진에 KioskApp 위젯을 실행하도록 지시
}

//StatelessWidget을 상속한 커스텀 위젯: 앱 전체를 대표하는 위젯
class KioskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(   //MaterialApp 위젯은 머티리얼 디자인을 사용하는 앱의 최상위 위젯
      title: 'Kiosk App',   //앱 이름
      theme: ThemeData(   //테마 설정: 앱 전체 기본 색상, 폰트 등 스타일 정의
        primarySwatch: Colors.indigo,   //주 색상 설정: 인디고
      ),
      initialRoute: '/',    //초기화면(route): 앱이 켜졌을 때 먼저 보일 경로 지정
      routes: {   //경로 문자열 키로, 해당 경로로 이동했을 때 보여줄 위젯을 값으로 등록
        '/': (_) => StartScreen(),    //루트 경로('/')로 오면 StartScreen 위젯 띄움
        '/menu': (_) => MenuScreen()    // '/menu' 경로로 오면 MenuScreen 위젯 띄움
      },
    );
  }
}
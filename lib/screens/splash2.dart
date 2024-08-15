import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login.dart';

// SplashScreen 클래스 정의
class Splash2 extends StatefulWidget {
  const Splash2({super.key});

  @override
  State<Splash2> createState() => _Splash2State();
}

// SplashScreen의 상태를 관리하는 클래스
class _Splash2State extends State<Splash2> with TickerProviderStateMixin {
  late PageController _pageViewController; // 페이지 전환을 위한 컨트롤러
  late TabController _tabController; // 탭 전환을 위한 컨트롤러

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController(); // PageController 초기화
    _tabController = TabController(length: 2, vsync: this); // 탭의 수를 2로 설정
  }

  @override
  void dispose() {
    _pageViewController.dispose(); // PageController 해제
    _tabController.dispose(); // TabController 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: Stack(
        alignment: Alignment.bottomCenter, // Stack의 정렬 방식
        children: <Widget>[
          // PageView로 페이지 전환 기능 구현
          PageView(
            controller: _pageViewController, // PageController 연결
            onPageChanged: _updateCurrentPageIndex, // 페이지가 변경될 때 호출
            children: [
              // 첫 번째 페이지
              _buildPage(
                imagePath: 'assets/wheel1.png',
                mainText: '휠체어 이동이 편한 장소만 \n              모았어요',
                subText: '출입이 어려워 다시 돌아가는 일은 이제 그만',
              ),
              // 두 번째 페이지
              _buildPage(
                imagePath: 'assets/map1.png',
                mainText: '내가 원하는 장소만 골라\n      코스를 만들어요',
                subText: '다른 테이퍼가 만든 코스도 확인해봐요!',
              ),
            ],
          ),
          // 페이지 인디케이터
          Positioned(
            bottom: 150,
            child: PageIndicator(
              tabController: _tabController, // TabController 전달
              currentPageIndex: _tabController.index, // 현재 페이지 인덱스
              onUpdateCurrentPageIndex:
                  _updateCurrentPageIndex, // 페이지 인덱스 업데이트 함수 전달
            ),
          ),
          if (_tabController.index == 1) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LogIn()));
                  },
                  child: Image.asset('assets/start1.png')),
            ),
          ],
        ],
      ),
    );
  }

  // 페이지를 구성하는 위젯 생성 함수
  Widget _buildPage(
      {required String imagePath,
      required String mainText,
      required String subText}) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(
            height: 200,
          ),
          Image.asset(imagePath, width: 350, height: 250),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Center(
              child: Text(
                mainText,
                style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.black), // 메인 텍스트 스타일
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                subText,
                style: const TextStyle(
                    fontSize: 15, color: Colors.black), // 서브 텍스트 스타일
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 페이지 인덱스를 업데이트하는 함수
  void _updateCurrentPageIndex(int index) {
    setState(() {
      _tabController.index = index; // TabController의 인덱스 업데이트
    });
    _pageViewController.animateToPage(
      index, // 이동할 페이지 인덱스
      duration: const Duration(milliseconds: 400), // 애니메이션 지속 시간
      curve: Curves.easeInOut, // 애니메이션 곡선
    );
  }
}

// 페이지 인디케이터 위젯 정의
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
  });

  final int currentPageIndex; // 현재 페이지 인덱스
  final TabController tabController; // TabController
  final void Function(int) onUpdateCurrentPageIndex; // 페이지 인덱스 업데이트 함수

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 가로 중앙 정렬
        children: <Widget>[
          TabPageSelector(
            controller: tabController, // TabController 연결
            selectedColor: Color(0xff4863E0), // 활성 색상
          ),
        ],
      ),
    );
  }
}

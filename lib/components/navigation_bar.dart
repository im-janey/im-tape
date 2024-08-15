import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/course/folder.dart';

class CustomNavigationBar extends StatefulWidget {
  final int selectedIndex; // 현재 선택된 탭의 인덱스
  final Function(int) onItemTapped; // 탭이 선택되었을 때 호출될 콜백 함수

  CustomNavigationBar(
      {super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 하단 네비게이션 바
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: _buildNavigationItems(),
          currentIndex: widget.selectedIndex,
          selectedItemColor: Color(0xff4863E0),
          unselectedItemColor: Colors.grey,
          onTap: widget.onItemTapped,
        ),
        // 중앙에 위치한 플로팅 액션 버튼
        _buildCenterFloatingActionButton(context),
      ],
    );
  }

  // 네비게이션 아이템 생성
  List<BottomNavigationBarItem> _buildNavigationItems() {
    return [
      _buildNavigationItem(Icons.home, '홈'),
      _buildNavigationItem(Icons.menu, '메뉴'),
    ];
  }

  // 개별 네비게이션 아이템 생성
  BottomNavigationBarItem _buildNavigationItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 40),
      label: label,
    );
  }

  // 중앙 플로팅 액션 버튼 생성
  Widget _buildCenterFloatingActionButton(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: MediaQuery.of(context).size.width / 2 - 28,
      child: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Folder()),
        ),
        backgroundColor: Color(0xff4863E0),
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

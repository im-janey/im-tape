import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:flutter_application_1/components/navigation_bar.dart';
import 'package:flutter_application_1/screens/course/cos.dart';
import 'package:flutter_application_1/screens/course/final.dart';

class Folder extends StatefulWidget {
  const Folder({super.key});
  @override
  State<Folder> createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _cards = [];
  List<String> _imagePaths = [];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCards();
    _loadImages(); // 이미지 경로 로드
  }

  // Firestore에서 사용자 데이터를 가져와 _cards에 저장
  Future<void> _loadCards() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        List<dynamic> cardData = userDoc['cards'] ?? [];
        setState(() {
          _cards = List<Map<String, dynamic>>.from(cardData);
        });
      }
    }
  }

  // assets 폴더에서 이미지 경로를 불러옴
  void _loadImages() {
    _imagePaths = [
      'assets/1.png',
      'assets/2.png',
      'assets/3.png',
      'assets/4.png',
      'assets/5.png',
      'assets/6.png',
      'assets/7.png',
      'assets/8.png',
      'assets/9.png',
      'assets/10.png',
      // 더 많은 이미지를 여기에 추가하세요
    ];
  }

  // Firestore에 코스 정보를 저장
  Future<void> _saveCard(String courseName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _cards.add({'courseName': courseName});
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'cards': _cards});
    }
  }

  // 코스 이름 입력 다이얼로그 표시
  void _showCourseNameDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.info_outline, size: 40, color: Colors.black),
                SizedBox(height: 16),
                Text(
                  '코스 이름 입력',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.flag),
                    hintText: '코스 이름을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        side: BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String courseName = controller.text;
                        _saveCard(courseName);
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavoritesList()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('설정'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 카드 삭제 함수
  void _removeCard(int index) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _cards.removeAt(index);
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'cards': _cards});
    }
  }

  Widget _buildCard(int index) {
    // 랜덤 이미지를 선택
    final random = Random();
    final imagePath = _imagePaths[random.nextInt(_imagePaths.length)];
    return Card(
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CosFrame()),
              );
            },
            child: Container(
              width: 175,
              height: 236,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.bottomCenter, // 글씨를 아래쪽에 위치
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0), // 아래쪽에 여백 추가
                child: Text(
                  _cards[index]['courseName'] ?? '코스 ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.black),
              onPressed: () => _removeCard(index),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '내가 만든 코스',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: _cards.length + 1, // 카드 리스트에 + 버튼 포함
          itemBuilder: (context, index) {
            if (index == _cards.length) {
              return Card(
                child: InkWell(
                  onTap: _showCourseNameDialog,
                  child: Container(
                    width: 160,
                    height: 200,
                    alignment: Alignment.center,
                    child: Icon(Icons.add, size: 50, color: Colors.black),
                  ),
                ),
              );
            } else {
              return _buildCard(index);
            }
          },
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/navigation_bar.dart';
import 'package:flutter_application_1/screens/favoriate.dart';
import 'package:flutter_application_1/screens/home.dart';
import 'package:flutter_application_1/screens/profile.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _profileImageUrl = '';
  String _nickname = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 사용자 데이터 로드
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _profileImageUrl = userData['image'] ?? '';
        _nickname = userData['nickname'] ?? '';
        _email = userData['email'] ?? '';
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      print("로그아웃 성공");
      // 로그아웃 후 이동할 페이지를 지정할 수 있습니다.
    } catch (e) {
      print("로그아웃 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 95),
                ListTile(
                  leading: _profileImageUrl.isNotEmpty
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(_profileImageUrl),
                          onBackgroundImageError: (exception, stackTrace) {
                            print('Error loading profile image: $exception');
                          },
                          child: _profileImageUrl.isEmpty
                              ? Icon(Icons.person)
                              : null,
                        )
                      : CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person),
                        ),
                  title: Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nickname,
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            _email,
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      )),
                ),
                SizedBox(height: 15),
                Divider(
                  color: Colors.black12,
                  thickness: 1,
                ),
                SizedBox(height: 5),
                ListTile(
                    leading: Image.asset(
                      'assets/profile.png',
                      width: 30,
                      height: 30,
                    ),
                    title: Text('프로필'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Profile()),
                      );
                    }),
                ListTile(
                  leading: Image.asset(
                    'assets/favorite.png',
                    width: 30,
                    height: 30,
                  ),
                  title: Text('찜한 장소'),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Favorite()),
                    );
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/personal.png',
                    width: 30,
                    height: 30,
                  ),
                  title: Text('개인정보 보호'),
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/inquiry.png',
                    width: 30,
                    height: 27,
                  ),
                  title: Text('문의하기'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: ListTile(
                    title: Text('버전'),
                    trailing:
                        Text('0.0.1     ', style: TextStyle(fontSize: 16)),
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          _logout();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: Text(
                          '로그아웃',
                          style: TextStyle(color: Colors.black, fontSize: 15.5),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: 1,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Home()));
          }
        },
      ),
    );
  }
}

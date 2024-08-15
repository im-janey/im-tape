import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _SignUp() async {
    final nickname = _nicknameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (nickname.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임, 이메일 및 비밀번호를 입력하세요.')),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 랜덤 이미지 선택
      QuerySnapshot randomSnapshot =
          await _firestore.collection('random').limit(1).get();
      if (randomSnapshot.docs.isNotEmpty) {
        DocumentSnapshot randomDoc = randomSnapshot.docs.first;
        List<String> imageLinks = List<String>.from(randomDoc['profile']);
        String randomImage = imageLinks[Random().nextInt(imageLinks.length)];

        // Firestore에 사용자 정보 저장 (랜덤 이미지 포함)
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'nickname': nickname,
          'email': email,
          'image': randomImage,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print("회원가입 성공: ${userCredential.user?.email}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공!')),
        );

        Navigator.pop(context);
      } else {
        throw Exception('랜덤 이미지를 찾을 수 없습니다.');
      }
    } catch (e) {
      print("회원가입 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 90),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: '닉네임',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff4863E0), width: 1.5),
                ),
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Color(0xff4863E0)),
              ),
              obscureText: false, // 변경: 텍스트 표시
              cursorColor: Color(0xff4863E0),
            ),
            const SizedBox(height: 13.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff4863E0), width: 1.5),
                ),
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Color(0xff4863E0)),
              ),
              obscureText: false, // 변경: 텍스트 표시
              cursorColor: Color(0xff4863E0),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 13.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff4863E0), width: 1.5),
                ),
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Color(0xff4863E0)),
              ),
              obscureText: true,
              cursorColor: Color(0xff4863E0),
            ),
            const SizedBox(height: 13.0),
            TextField(
              controller: TextEditingController(), // 비밀번호 확인 필드는 별도로 처리
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff4863E0), width: 1.5),
                ),
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Color(0xff4863E0)),
              ),
              obscureText: true,
              cursorColor: Color(0xff4863E0),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: _SignUp,
              child: Image.asset('assets/sign.png'),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 예시로 이전 페이지로 돌아가는 코드
              },
              child: const Text.rich(
                TextSpan(
                  text: '이미 계정이 있으신가요? ',
                  style: TextStyle(color: Color(0xff4863E0)),
                  children: <TextSpan>[
                    TextSpan(
                      text: '로그인',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/signup.dart';
import 'package:flutter_application_1/screens/home.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _LogIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // 로그인 성공 후 동작
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      print("로그인 성공: ${userCredential.user?.email}");
    } catch (e) {
      // 로그인 실패 시 에러 메시지 출력
      print("로그인 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: 다시 입력해주세요 ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(
                height: 150,
              ),
              SizedBox(
                width: 230,
                child: Image.asset('assets/typelogo.png'),
              ),
              SizedBox(
                height: 25,
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fillColor: Color(0xffB6C1F3),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          BorderSide(color: Color(0xffB6C1F3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          BorderSide(color: Color(0xffB6C1F3), width: 2),
                    ),
                    floatingLabelStyle: TextStyle(color: Color(0xff4863E0)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Color(0xff4863E0),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fillColor: Color(0xffB6C1F3),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          BorderSide(color: Color(0xffB6C1F3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          BorderSide(color: Color(0xffB6C1F3), width: 2),
                    ),
                    floatingLabelStyle: TextStyle(color: Color(0xff4863E0)),
                  ),
                  obscureText: true,
                  cursorColor: Color(0xff4863E0),
                ),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: _LogIn,
                child: const Text(
                  '로그인',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUp()),
                  );
                },
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

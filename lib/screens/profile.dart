import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/menu.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _profileImageUrl = '';
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
        _nicknameController.text = userData['nickname'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _profileImageUrl = userData['image'] ?? '';
      });
    }
  }

  // 사용자 데이터 업데이트
  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'nickname': _nicknameController.text.trim(),
        'email': _emailController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 편집'),
        actions: [
          TextButton(
            onPressed: () async {
              await _updateUserData();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Menu()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 5, right: 20),
              child: Text(
                '완료',
                style: TextStyle(
                  color: Color(0xff4863E0),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: _profileImageUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(_profileImageUrl),
                      onBackgroundImageError: (exception, stackTrace) {
                        print('Error loading profile image: $exception');
                      },
                      child:
                          _profileImageUrl.isEmpty ? Icon(Icons.person) : null,
                    )
                  : CircleAvatar(
                      radius: 80,
                      child: Icon(Icons.person),
                    ),
            ),
            const SizedBox(height: 30),
            _buildTextField('닉네임', _nicknameController),
            _buildTextField('이메일', _emailController),
            ListTile(
              trailing: TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangePasswordPage())),
                child: const Text('비밀번호 변경',
                    style: TextStyle(color: Color(0xff4863E0), fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 텍스트 필드 위젯 생성
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: ListTile(
          leading: Text(label,
              style: const TextStyle(fontSize: 17, color: Colors.black)),
          title: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              hintText: '$label을 입력하세요',
              hintStyle:
                  const TextStyle(color: Color(0xFFA7A7A7), fontSize: 16),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xff4863E0), width: 1.5),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ));
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 비밀번호 변경 로직
  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 비밀번호와 비밀번호 확인이 일치하지 않습니다.')),
      );
      return;
    }
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(_newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 변경 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 변경'),
        actions: [
          TextButton(
            onPressed: () async {
              await _changePassword();
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 5, right: 20),
              child: Text(
                '완료',
                style: TextStyle(
                  color: Color(0xff4863E0),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPasswordField('현재 비밀번호', _currentPasswordController),
            const SizedBox(height: 16),
            _buildPasswordField('새 비밀번호', _newPasswordController),
            const SizedBox(height: 16),
            _buildPasswordField('비밀번호 확인', _confirmPasswordController),
          ],
        ),
      ),
    );
  }

  // 비밀번호 입력 필드 위젯 생성
  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            hintStyle: const TextStyle(color: Color(0xFFA7A7A7), fontSize: 16),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff4863E0), width: 1.5),
            ),
            floatingLabelStyle: TextStyle(color: Color(0xff4863E0)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ));
  }
}

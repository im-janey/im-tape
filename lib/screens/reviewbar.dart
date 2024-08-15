import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Rating extends StatefulWidget {
  final String collectionName; // 컬렉션 이름 (예: 'restaurant', 'cafe')
  final String id; // 기존 문서 ID
  final Map<String, String> ratingFields; // 동적으로 설정할 필드와 라벨

  const Rating({
    super.key,
    required this.collectionName,
    required this.id,
    required this.ratingFields,
  });

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _textController = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser!.uid; // 현재 사용자의 ID
  final Map<String, int> _ratings = {}; // 각 필드의 평점 값을 저장할 맵
  String _profileImageUrl = '';
  String _nickname = ''; // Initialize with an empty string

  @override
  void initState() {
    super.initState();
    // 초기화: 각 필드의 평점을 0으로 설정
    widget.ratingFields.forEach((key, _) {
      _ratings[key] = 0;
    });
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _nickname = userData['nickname'] ?? '';
        _profileImageUrl = userData['image'] ?? '';
      });
    }
  }

  // 이미 리뷰를 작성했는지 확인하는 함수
  Future<bool> _hasAlreadyReviewed() async {
    final review = await _firestore
        .collection(widget.collectionName)
        .doc(widget.id) // 기존 문서 참조
        .collection('ratings') // 서브컬렉션 참조
        .where('userId', isEqualTo: userId)
        .limit(1) // 성능을 위해 limit를 추가
        .get();
    return review.docs.isNotEmpty;
  }

  // 별점을 제출하는 함수
  void _submitRating() async {
    String reviewText = _textController.text.trim();
    Navigator.of(context).pop();
    // 모든 필드가 0보다 큰지 확인
    if (_ratings.values.every((rating) => rating > 0)) {
      if (await _hasAlreadyReviewed()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 리뷰를 작성했습니다!')),
        );
        return;
      }
      // 제출할 데이터를 준비
      Map<String, dynamic> reviewData = {
        'userId': userId,
        'review': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      };
      // 각 필드의 평점을 추가
      reviewData.addAll(_ratings);
      // Firestore에 데이터 저장
      _firestore
          .collection(widget.collectionName)
          .doc(widget.id) // 기존 문서에 서브컬렉션으로 저장
          .collection('ratings')
          .add(reviewData)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰가 저장되었습니다!')),
        );
        setState(() {
          // 초기화
          _ratings.updateAll((key, value) => 0);
          _textController.clear();
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 항목의 별점을 선택하세요!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '리뷰 작성',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Row(
              children: [
                _profileImageUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(_profileImageUrl),
                        onBackgroundImageError: (exception, stackTrace) {
                          print('Error loading profile image: $exception');
                        },
                        child: _profileImageUrl.isEmpty
                            ? Icon(Icons.person)
                            : null,
                      )
                    : CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person),
                      ),
                Text(
                  _nickname,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            // 동적으로 각 필드를 표시
            ...widget.ratingFields.entries.map((entry) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        entry.value,
                        style: TextStyle(fontSize: 20),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _ratings[entry.key]!
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Color(0xff4863E0),
                            ),
                            iconSize: 30,
                            onPressed: () {
                              setState(() {
                                _ratings[entry.key] = index + 1;
                              });
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              );
            }),
            SizedBox(
              width: double.infinity,
              height: 150,
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: '이곳에 다녀온 경험을 자세히 공유해주세요\n\n\n',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                maxLines: null,
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
                onPressed: _submitRating,
                child: Image.asset('assets/finish1.png'))
          ],
        ),
      ),
    );
  }
}

class ReviewList extends StatelessWidget {
  final String collectionName; // 컬렉션 이름 (예: 'restaurant')
  final String id; // 문서 ID
  const ReviewList({
    super.key,
    required this.collectionName,
    required this.id,
  });
  Future<String> _getUserName(String userId) async {
    // Firestore에서 사용자 정보 가져오기
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc['nickname'] != null) {
      return userDoc['nickname']; // 사용자의 닉네임 반환
    } else {
      return '익명'; // 닉네임이 없을 경우 익명으로 표시
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
          .doc(id)
          .collection('ratings')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var reviewDoc = snapshot.data!.docs[index];
            var reviewData = reviewDoc.data() as Map<String, dynamic>?;
            if (reviewData == null) {
              return ListTile(title: Text('리뷰 데이터를 불러올 수 없습니다.'));
            }
            String userId = reviewData['userId'] as String;
            return FutureBuilder<String>(
              future: _getUserName(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text('로딩 중...'),
                    subtitle: Text('잠시만 기다려주세요.'),
                  );
                }
                if (snapshot.hasError) {
                  return ListTile(
                    title: Text('오류 발생'),
                    subtitle: Text('사용자 정보를 불러오는데 실패했습니다.'),
                  );
                }
                String userName = snapshot.data ?? '익명';
                return ListTile(
                  leading: Text(userName,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  title: Wrap(
                    spacing: 6.0, // 항목 간의 간격을 추가
                    runSpacing: 8.0, // 줄 바꿈 시 항목 간의 간격을 추가
                    children: [
                      // 총별점은 별점으로 표시
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('총점: '),
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < (reviewData['총별점'] as int? ?? 0)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Color(0xff4863E0),
                                size: 20,
                              );
                            }),
                          ),
                        ],
                      ),
                      SizedBox(width: 80),
                      // 나머지 항목들을 가로로 표시
                      ...reviewData.entries.map((entry) {
                        if (entry.key != 'userId' &&
                            entry.key != 'review' &&
                            entry.key != 'timestamp' &&
                            entry.key != '총별점') {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${entry.key}: '),
                              Text(
                                entry.value.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }
                        return SizedBox.shrink();
                      }),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(reviewData['review'] as String? ?? '리뷰 내용 없음'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ReviewPage extends StatefulWidget {
  final String collectionName; // 컬렉션 이름 (예: 'restaurant', 'cafe')
  final String id; // 문서 ID
  final Map<String, String> ratingFields; // 동적으로 설정할 필드와 라벨
  const ReviewPage({
    super.key,
    required this.collectionName,
    required this.id,
    required this.ratingFields,
  });
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 40),
            SizedBox(width: 40),
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Rating(
                        collectionName: widget.collectionName,
                        id: widget.id,
                        ratingFields: widget.ratingFields,
                      ),
                    ),
                  );
                },
                child: Image.asset('assets/rating1.png'),
              ),
            ),
          ],
        ),
        Expanded(
          child: ReviewList(
            collectionName: widget.collectionName,
            id: widget.id,
          ),
        ),
      ],
    );
  }
}

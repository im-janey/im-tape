import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Rating extends StatefulWidget {
  final String collectionName; // 컬렉션 이름 (예: 'restaurant', 'hotel')
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _textController = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser!.uid; // 현재 사용자의 ID

  final Map<String, int> _ratings = {}; // 각 필드의 평점 값을 저장할 맵

  @override
  void initState() {
    super.initState();
    // 초기화: 각 필드의 평점을 0으로 설정
    widget.ratingFields.forEach((key, _) {
      _ratings[key] = 0;
    });
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 동적으로 각 필드를 표시
            ...widget.ratingFields.entries.map((entry) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        entry.value,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
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

            return ListTile(
              leading: SizedBox(),
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
                  SizedBox(
                    width: 80,
                  ),
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
                  }).toList(),
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

class InfoPage extends StatelessWidget {
  final String collectionName;
  final String id;

  const InfoPage({
    super.key,
    required this.collectionName,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collectionName)
            .doc(id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data available for this document'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          var open = data['open'] as String?;
          var call = data['call'] as String?;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(
                  icon: Icons.access_time,
                  title: '영업시간',
                  content:
                      open != null ? open.replaceAll('\\n', '\n') : '정보 없음',
                ),
                Divider(thickness: 0.7, color: Colors.grey),
                _buildInfoSection(
                  icon: Icons.phone,
                  title: '전화번호',
                  content: call ?? '정보 없음',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.all(23.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 15)),
            ],
          ),
          SizedBox(height: 12),
          Text(content),
        ],
      ),
    );
  }
}

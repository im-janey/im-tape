import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/infobar.dart';
import 'package:flutter_application_1/screens/menubar.dart';
import 'package:flutter_application_1/screens/reviewbar.dart';

class DetailPage extends StatefulWidget {
  final String name;
  final String address;
  final String subname;
  final Map<String, dynamic> data;
  final String id;
  final String collectionName; // 컬렉션 이름 추가

  DetailPage({
    super.key,
    required this.name,
    required this.subname,
    required this.data,
    required this.address,
    required this.id,
    required this.collectionName, // 컬렉션 이름 초기화
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final FavoriteService _favoriteService = FavoriteService();
  bool _isFavorited = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    List<String> favorites = await _favoriteService.getFavorite(userId);
    setState(() {
      _isFavorited = favorites.contains(widget.id);
    });
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    try {
      if (_isFavorited) {
        await _favoriteService.addFavorite(userId, widget.id);
      } else {
        await _favoriteService.removeFavorite(userId, widget.id);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = widget.data['images'] is List
        ? List<String>.from(widget.data['images'])
        : [];
    List<String> banners = widget.data['banner'] is List
        ? List<String>.from(widget.data['banner'])
        : [];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        leading: Padding(
          padding: const EdgeInsets.only(left: 22, bottom: 40),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 20,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 7),
              Text(
                widget.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                widget.address,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              if (images.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      images[0],
                      height: 17,
                      fit: BoxFit.contain,
                    ),
                  ],
                )
              else
                Text('아직 만드는 중...'),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    color: _isFavorited ? Color(0xff4863E0) : Colors.black12,
                    size: 26,
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    '찜하기',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isFavorited ? Color(0xff4863E0) : Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 25.0, top: 8.0, right: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                SizedBox(width: 35), // 왼쪽 여백
                ...List.generate(
                  3,
                  (index) {
                    if (images.length > index + 1) {
                      return Image.network(
                        images[index + 1],
                        width: 80,
                        fit: BoxFit.contain,
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
            SizedBox(height: 17),
            if (banners.isNotEmpty)
              SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    String imageUrl = banners[index];
                    if (imageUrl.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            imageUrl,
                            width: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else {
                      return Center(child: Text('이미지가 없습니다.'));
                    }
                  },
                ),
              )
            else
              Text(
                '아직 만드는 중',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            SizedBox(height: 8.0),
            TabBar(
              controller: _tabController,
              indicatorColor: Color(0xffbac4863E0),
              labelColor: Color(0xffbac4863E0),
              tabs: const [
                Tab(
                  child: Text(
                    '리뷰',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    '정보',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    '메뉴',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ReviewPage(
                    collectionName: widget.collectionName, // 컬렉션 이름 전달
                    id: widget.id,
                    ratingFields: LinkedHashMap<String, String>.from({
                      '총별점': '    총점',
                      '출입': '휠체어 출입',
                      '좌석': '휠체어 좌석',
                      '친절': '   친절도',
                    }),
                  ),
                  InfoPage(
                    collectionName: widget.collectionName,
                    id: widget.id,
                  ),
                  menubar(
                    collectionName: widget.collectionName,
                    id: widget.id,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addFavorite(String userId, String storeId) async {
    DocumentReference userRef = _firestore.collection('users').doc(userId);
    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        // 사용자 문서가 없으면 새로 생성
        transaction.set(userRef, {
          'favorites': [storeId]
        });
      } else {
        List<dynamic> favorites =
            (snapshot.data() as Map<String, dynamic>)['favorites'] ?? [];
        if (!favorites.contains(storeId)) {
          favorites.add(storeId);
          transaction.update(userRef, {'favorites': favorites});

          print(storeId);
        }
      }
    });
  }

  Future<List<String>> getFavorite(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return List<String>.from(data['favorites'] ?? []);
    } else {
      return [];
    }
  }

  Future<void> removeFavorite(String userId, String storeId) async {
    DocumentReference userRef = _firestore.collection('users').doc(userId);
    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      List<dynamic> favorites =
          (snapshot.data() as Map<String, dynamic>)['favorites'] ?? [];
      favorites.remove(storeId);
      transaction.update(userRef, {'favorites': favorites});
    });
  }
}

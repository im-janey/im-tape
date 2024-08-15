import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/map/detailpage.dart';

class Favorite extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('찜')),
      body: SingleChildScrollView(
        child: StreamBuilder<List<String>>(
          // firebase에서 user의 favorite 필드에 저장된 storeid list를 실시간으로 가져옴
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots()
              .map((snapshot) =>
                  (snapshot.data()?['favorites'] as List<dynamic>? ?? [])
                      .cast<String>()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('오류가 발생했습니다.'));
            }
            if (snapshot.data?.isEmpty ?? true) {
              return Center(child: Text('찜한 가게가 없습니다.'));
            }
            List<String> favoriteStoreIds = snapshot.data!;
            // favorite store id list를 받아가지고 더 자세한 정보에 fetch해가지고 ui를 만듦
            return FutureBuilder<List<DocumentSnapshot>>(
              future: _fetchFavoriteStores(favoriteStoreIds),
              builder: (context, storeSnapshot) {
                if (storeSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (storeSnapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다.'));
                }
                List<DocumentSnapshot> stores = storeSnapshot.data ?? [];
                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 40.0,
                      crossAxisSpacing: 10.0, // 추가: 아이템 간의 가로 간격 조정
                      childAspectRatio: 0.7, // 추가: 아이템의 가로 세로 비율 조정
                    ),
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      var store = stores[index];
                      return _buildStoreCard(context, store);
                    },
                    shrinkWrap: true, // 추가: GridView가 필요한 만큼만 공간을 차지하도록 함
                    physics: NeverScrollableScrollPhysics(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // favorite store id를 firestore의 다른 collection에서 찾아서 세부 정보를 가져오는 함수
  Future<List<DocumentSnapshot>> _fetchFavoriteStores(
      List<String> storeIds) async {
    List<String> categories = ['restaurant', 'cafe', 'park', 'display', 'play'];
    List<QuerySnapshot> querySnapshots = await Future.wait(categories.map(
        (category) => FirebaseFirestore.instance
            .collection(category)
            .where(FieldPath.documentId, whereIn: storeIds)
            .get()));
    return querySnapshots.expand((snapshot) => snapshot.docs).toList();
  }

  Widget _buildStoreCard(BuildContext context, DocumentSnapshot store) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPage(
            name: store['name'],
            subname: store['subname'],
            data: store.data() as Map<String, dynamic>,
            address: store['address'],
            id: store.id,
            collectionName: store.reference.parent.id, // 컬렉션 이름을 가져옵니다
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                image: DecorationImage(
                  image: NetworkImage(store['banner'][0]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    store['subname'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

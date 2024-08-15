import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/home.dart';
import 'package:flutter_application_1/screens/map/detailpage.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<String> collections = [
    'cafe',
    'restaurant',
    'park',
    'display',
    'play'
  ]; // 검색할 컬렉션 목록

  void _performSearch() async {
    String query = _searchController.text;

    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    List<Map<String, dynamic>> allResults = [];

    // 모든 컬렉션에 대해 검색 실행
    for (String collection in collections) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      // 검색 결과와 컬렉션 이름을 함께 저장
      for (var doc in snapshot.docs) {
        allResults.add({
          'data': doc.data(),
          'collectionName': collection, // 컬렉션 이름 추가
          'id': doc.id, // 문서 ID 추가
        });
      }
    }

    setState(() {
      searchResults = allResults; // 모든 검색 결과를 하나의 리스트로 합침
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController, // 검색어 입력을 위한 컨트롤러
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _performSearch, // 검색 버튼 클릭 시 검색 실행
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Text('취소'), // 취소 버튼
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home()), // 홈 화면으로 돌아가기
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: searchResults.isEmpty
                  ? Center(child: Text('검색 결과가 없습니다.'))
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        var data = searchResults[index]['data']
                            as Map<String, dynamic>;
                        String collectionName =
                            searchResults[index]['collectionName'];
                        String docId = searchResults[index]['id'];

                        // banner 배열에서 첫 번째 이미지를 가져옵니다.
                        String? bannerImageUrl;
                        if (data['banner'] != null &&
                            data['banner'] is List &&
                            (data['banner'] as List).isNotEmpty) {
                          bannerImageUrl = (data['banner'] as List)[0];
                        }

                        return ListTile(
                          leading: bannerImageUrl != null
                              ? Image.network(
                                  bannerImageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error);
                                  },
                                )
                              : Icon(Icons
                                  .image_not_supported), // 이미지가 없을 때 아이콘 표시
                          title: Text(data['name'] ?? 'No Name'), // 이름 표시
                          subtitle:
                              Text(data['address'] ?? 'No Address'), // 주소 표시
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  collectionName: collectionName, // 컬렉션 이름 전달
                                  name: data['name'] ?? 'No Name',
                                  address: data['address'] ?? 'No Address',
                                  subname: data['subname'] ?? '',
                                  data: data,
                                  id: docId, // 문서 ID 전달
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

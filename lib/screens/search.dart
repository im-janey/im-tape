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
  final List<String> collections = [
    'cafe',
    'restaurant',
    'park',
    'display',
    'play'
  ];

  void _performSearch() async {
    String query = _searchController.text;
    if (query.isEmpty) {
      setState(() => searchResults.clear());
      return;
    }

    List<Map<String, dynamic>> results = [];
    for (String collection in collections) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      results.addAll(snapshot.docs.map((doc) => {
            'data': doc.data() as Map<String, dynamic>,
            'collectionName': collection,
            'id': doc.id,
          }));
    }

    setState(() => searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 110,
        title: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, size: 28),
                      onPressed: _performSearch,
                    ),
                  ),
                  cursorColor: Color(0xff4863E0),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 5, right: 20),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
              child: const Text(
                '취소',
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: searchResults.isEmpty
                  ? Center(child: Text('검색 결과가 없습니다.'))
                  : Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          var item = searchResults[index];
                          var data = item['data'] as Map<String, dynamic>;
                          String? bannerImageUrl =
                              data['banner'] is List ? data['banner'][0] : null;

                          return ListTile(
                            leading: bannerImageUrl != null
                                ? Image.network(bannerImageUrl,
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : Icon(Icons.image_not_supported),
                            title: Text(data['name'] ?? 'No Name'),
                            subtitle: Text(data['address'] ?? 'No Address'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPage(
                                  collectionName: item['collectionName'],
                                  name: data['name'] ?? 'No Name',
                                  address: data['address'] ?? 'No Address',
                                  subname: data['subname'] ?? '',
                                  data: data,
                                  id: item['id'],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class menubar extends StatelessWidget {
  final String collectionName; // 컬렉션 이름
  final String id; // 문서 ID

  const menubar({super.key, required this.collectionName, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collectionName) // 외부에서 받은 컬렉션 이름 사용
            .doc(id) // 외부에서 받은 문서 ID 사용
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

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(collectionName)
                .doc(id)
                .collection('menufood') // 'menufood' 서브 컬렉션은 고정
                .snapshots(),
            builder: (context, menuSnapshot) {
              if (menuSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (menuSnapshot.hasError) {
                return Center(child: Text('Error: ${menuSnapshot.error}'));
              }
              if (!menuSnapshot.hasData || menuSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('No menu available'));
              }

              return ListView(
                children: [
                  ...menuSnapshot.data!.docs.map(
                    (menuDoc) {
                      var data = menuDoc.data() as Map<String, dynamic>;

                      // 데이터를 안전하게 변환합니다.
                      List<String> names =
                          List<String>.from(data['name'] ?? []);
                      List<String> prices =
                          List<String>.from(data['price'] ?? []);
                      List<String> images =
                          List<String>.from(data['images'] ?? []);

                      return Column(
                        children: [
                          SizedBox(height: 10),
                          ...List.generate(
                            names.length,
                            (i) => Padding(
                              padding: EdgeInsets.only(
                                left: 5,
                                right: 5,
                              ),
                              child: ListTile(
                                leading:
                                    images.isNotEmpty && images[i].isNotEmpty
                                        ? Image.network(
                                            images[i],
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(Icons.error);
                                            },
                                          )
                                        : Icon(Icons.fastfood),
                                title: Text(names[i]),
                                subtitle: Text(
                                  prices[i],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

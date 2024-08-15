import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

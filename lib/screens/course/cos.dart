import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesList extends StatefulWidget {
  FavoritesList({super.key});

  @override
  _FavoritesListState createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  int _selectedCount = 0;
  final List<Map<String, dynamic>> _selectedPlaces = []; // 선택한 장소들 저장
  final Set<String> _selectedPlaceIds = {}; // 선택된 장소의 ID를 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: Text(
                '코스만들기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildTimeline(),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Google Map 배경
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(37.5665, 126.9780),
              zoom: 11.0,
            ),
            markers: _markers,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                color: Colors.white,
                child: FutureBuilder<DocumentSnapshot>(
                  future: _getUserDocument(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('오류가 발생했습니다.'));
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(child: Text('코스만들기'));
                    }

                    Map<String, dynamic> userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    List<String> favoriteIds =
                        List<String>.from(userData['favorites'] ?? []);

                    return FutureBuilder<List<DocumentSnapshot>>(
                      future: _fetchFavoriteDocuments(favoriteIds),
                      builder: (context, docSnapshot) {
                        if (docSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (docSnapshot.hasError) {
                          return Center(child: Text('오류가 발생했습니다.'));
                        }

                        List<DocumentSnapshot> favoriteDocs =
                            docSnapshot.data ?? [];

                        if (favoriteDocs.isEmpty) {
                          return Center(child: Text('코스만들기가 없습니다.'));
                        }

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 160,
                                  ),
                                  Text(
                                    '찜',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 110,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _saveSelectedPlaces(); // 완료 버튼을 눌렀을 때 선택한 장소 저장
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.white, // 버튼 배경색 설정
                                    ),
                                    child: Text(
                                      '완료',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              thickness: 1,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: favoriteDocs.length,
                                itemBuilder: (context, index) {
                                  var data = favoriteDocs[index].data()
                                      as Map<String, dynamic>;

                                  List<String> images = data['banner'] is List
                                      ? List<String>.from(data['banner'])
                                      : [];

                                  String placeId = favoriteDocs[index].id;

                                  return ListTile(
                                    leading: images.isNotEmpty
                                        ? Image.network(
                                            images[0],
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(Icons.image_not_supported),
                                    title: Text(data['name'] ?? 'No Name'),
                                    subtitle:
                                        Text(data['subname'] ?? 'No Subname'),
                                    trailing: ElevatedButton(
                                      onPressed:
                                          _selectedPlaceIds.contains(placeId)
                                              ? null
                                              : () {
                                                  _selectPlace(data, placeId);
                                                },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _selectedPlaceIds
                                                .contains(placeId)
                                            ? Colors.grey[300]
                                            : Colors.white, // 이미 선택된 경우 비활성화
                                      ),
                                      child: Text(
                                        '선택',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _selectPlace(Map<String, dynamic> data, String placeId) {
    if (_selectedCount >= 4) {
      // 이미 4개의 장소가 선택된 경우, 추가하지 않음
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 4개의 장소만 선택할 수 있습니다.')),
      );
      return;
    }

    setState(() {
      _selectedPlaces.add(data); // 선택한 장소를 리스트에 추가
      _selectedPlaceIds.add(placeId); // 선택된 장소의 ID를 저장
      _selectedCount++;

      // 장소를 선택할 때마다 마커를 지도에 추가
      if (data['location'] != null && data['location'] is GeoPoint) {
        GeoPoint geoPoint = data['location'];
        LatLng position = LatLng(geoPoint.latitude, geoPoint.longitude);

        _markers.add(
          Marker(
            markerId: MarkerId(data['name'] ?? ''),
            position: position,
            infoWindow: InfoWindow(
              title: data['name'] ?? 'No Name',
              snippet: data['subname'] ?? '',
            ),
          ),
        );

        _mapController?.animateCamera(CameraUpdate.newLatLng(position));
      }
    });
  }

  void _saveSelectedPlaces() async {
    if (_selectedPlaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('장소를 선택하지 않았습니다.')),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 선택한 장소들을 Firestore에 저장
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'selected_places': _selectedPlaces,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('선택한 장소들이 저장되었습니다.')),
    );
  }

  Widget _buildTimeline() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(4, (index) {
          return Row(
            children: [
              _buildTimelineNode(index < _selectedCount),
              if (index < 3) _buildTimelineLine(index < _selectedCount),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTimelineNode(bool isFilled) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Color(0xff4863E0) : Colors.white, // 내부 배경 색상
            border: Border.all(
              color: Color(0xff4863E0), // 외곽선 색상
              width: 2, // 외곽선 두께
            ),
          ),
          child: isFilled
              ? Container() // 선택된 상태의 경우 내부를 채우지 않음
              : null, // 선택되지 않은 상태에서는 내부가 비어 있음
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isFilled) {
    return Container(
      width: 60,
      height: 2,
      color: isFilled ? Colors.blue : Colors.grey,
    );
  }

  Future<DocumentSnapshot> _getUserDocument() async {
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }

  Future<List<DocumentSnapshot>> _fetchFavoriteDocuments(
      List<String> favoriteIds) async {
    List<DocumentSnapshot> allDocs = [];
    List<String> collections = [
      'cafe',
      'restaurant',
      'park',
      'display',
      'play'
    ];

    for (String collection in collections) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where(FieldPath.documentId, whereIn: favoriteIds)
          .get();

      allDocs.addAll(snapshot.docs);
    }

    return allDocs;
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
    final List<LatLng> positions = markers.map((m) => m.position).toList();

    double minLat =
        positions.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat =
        positions.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng =
        positions.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng =
        positions.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

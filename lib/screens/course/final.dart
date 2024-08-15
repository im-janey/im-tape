import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/map/detailpage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CosFrame extends StatefulWidget {
  CosFrame({super.key});

  @override
  _CosFrameState createState() => _CosFrameState();
}

class _CosFrameState extends State<CosFrame> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  final List<String> _collections = [
    'cafe',
    'restaurant',
    'park',
    'display',
    'play'
  ];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    DocumentSnapshot userDoc = await _getUserDocument();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    List<Map<String, dynamic>> selectedPlaces =
        List<Map<String, dynamic>>.from(userData['selected_places'] ?? []);

    for (var place in selectedPlaces) {
      _addMarker(place);
    }

    if (_markers.isNotEmpty) {
      _adjustCameraView();
    }
  }

  Future<String> _findCollectionForDocument(String docId) async {
    for (String collection in _collections) {
      var docSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .get();
      if (docSnapshot.exists) {
        return collection;
      }
    }
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3.5,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.5665, 126.9780),
                    zoom: 11.0,
                  ),
                  markers: _markers,
                ),
              ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future: _getUserDocument(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다.'));
                }

                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                List<Map<String, dynamic>> selectedPlaces =
                    List<Map<String, dynamic>>.from(
                        userData['selected_places'] ?? []);

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3 / 4,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  itemCount: selectedPlaces.length,
                  itemBuilder: (context, index) {
                    var data = selectedPlaces[index];
                    String docId = data['id'] ?? 'id';
                    List<String> images = data['banner'] is List
                        ? List<String>.from(data['banner'])
                        : [];

                    return FutureBuilder<String>(
                      future: _findCollectionForDocument(docId),
                      builder: (context, collectionSnapshot) {
                        if (collectionSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        String collectionName =
                            collectionSnapshot.data ?? 'unknown';

                        return InkWell(
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
                          child: GridTile(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      child: images.isNotEmpty
                                          ? Image.network(
                                              images[0],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : Icon(Icons.image_not_supported,
                                              size: 50),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'] ?? 'No Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          data['address'] ?? 'No Address',
                                          style: TextStyle(color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addMarker(Map<String, dynamic> data) {
    if (data['location'] != null && data['location'] is GeoPoint) {
      GeoPoint geoPoint = data['location'];
      LatLng position = LatLng(geoPoint.latitude, geoPoint.longitude);

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(data['name'] ?? ''),
            position: position,
            infoWindow: InfoWindow(
              title: data['name'] ?? 'No Name',
              snippet: data['address'] ?? '',
            ),
          ),
        );
      });
    }
  }

  void _adjustCameraView() {
    if (_markers.isEmpty) return;

    LatLngBounds bounds = _calculateBounds(_markers);
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
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

  Future<DocumentSnapshot> _getUserDocument() async {
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }
}

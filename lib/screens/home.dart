import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/navigation_bar.dart';
import 'package:flutter_application_1/screens/all.dart';
import 'package:flutter_application_1/screens/map/cafe.dart';
import 'package:flutter_application_1/screens/map/display.dart';
import 'package:flutter_application_1/screens/map/food.dart';
import 'package:flutter_application_1/screens/map/park.dart';
import 'package:flutter_application_1/screens/map/play.dart';
import 'package:flutter_application_1/screens/menu.dart';
import 'package:flutter_application_1/screens/banner1.dart';
import 'package:flutter_application_1/screens/search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Menu()));
    }
  }

  Widget _buildIconButton(String asset, Widget destination) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      ),
      child: Image.asset(asset, height: 55, width: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 120,
        title: Image.asset('assets/firstlogo.png', width: 200, height: 100),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => Search())),
            icon: Icon(Icons.search, size: 30),
            padding: EdgeInsets.only(right: 30),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 15),
          Banner1(),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    _buildIconButton('assets/bob.png', Frame()),
                    SizedBox(height: 13),
                    _buildIconButton('assets/display.png', DisplayFrame()),
                  ],
                ),
                Column(
                  children: [
                    _buildIconButton('assets/cafe.png', CafeFrame()),
                    SizedBox(height: 13),
                    _buildIconButton('assets/play.png', PlayFrame()),
                  ],
                ),
                Column(
                  children: [
                    _buildIconButton('assets/park.png', ParkFrame()),
                    SizedBox(height: 13),
                    _buildIconButton('assets/all.png', AllPlacesFrame()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

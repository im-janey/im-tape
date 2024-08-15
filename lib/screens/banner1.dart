import 'package:flutter/material.dart';

class Banner1 extends StatefulWidget {
  const Banner1({super.key});

  @override
  State<Banner1> createState() => _Banner1State();
}

class _Banner1State extends State<Banner1> {
  final PageController _pageController = PageController(viewportFraction: 0.8);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 305,
      width: 400,
      child: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
              child: Image.asset('assets/ban1.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
              child: Image.asset('assets/ban2.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
              child: Image.asset('assets/ban3.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
              child: Image.asset('assets/ban4.png'),
            ),
          ),
        ],
      ),
    );
  }
}

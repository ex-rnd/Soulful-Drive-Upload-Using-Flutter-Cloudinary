// lib/tests/chains_test.dart

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../screens/chains.dart';
import '../screens/rosters.dart';
import '../screens/spotlets.dart';
import '../screens/streams.dart';
import '../screens/vaults.dart';

class ChainsTest extends StatefulWidget {
  const ChainsTest({super.key});

  @override
  State<ChainsTest> createState() => _ChainsTestState();
}

class _ChainsTestState extends State<ChainsTest> {

  int _currentIndex = 0;

  final List<Widget> _screens = [
    Chains(),
    Streams(),
    Spots(),
    Vaults(),
    Rosters(),
  ];



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF4B352A),
      child: SafeArea(
        top: false,
        left: false,
        right: false,

        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF4B352A),
            foregroundColor: Colors.white,
            title: Text(
              "Chains Test ...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: _screens[_currentIndex],
          bottomNavigationBar: CurvedNavigationBar(
          color: Color(0xFF4B352A),
          buttonBackgroundColor: Color(0xFFCA7842),
          backgroundColor: Colors.transparent,
          onTap: (value) {
            setState(() {
              _currentIndex = value;
            });
          },


            items: [
              Icon(
                _currentIndex == 0
                ? Icons.record_voice_over
                : Icons.voice_chat,
                size: 30,
                color: Colors.white,
              ),

              Icon(
                _currentIndex == 1
                ? Icons.voice_chat_sharp
                : Icons.voice_chat_outlined,
                size: 30,
                color: Colors.white
              ),

              Icon(
                _currentIndex == 2
                ? Icons.add_a_photo
                : Icons.add_a_photo_outlined,
                size: 30,
                color: Colors.white
              ),

              Icon(
                _currentIndex == 3
                ? Icons.file_present
                : Icons.file_present_outlined,
                size: 30,
                color: Colors.white
              ),

              Icon( // dashboard_outlined
                _currentIndex == 4
                ? Icons.dashboard
                : Icons.dashboard_outlined,
                size: 30,
                color: Colors.white
              ),

            ]),
        ),
      ),
    );
  }
}




// Version 1
//
// class ChainsTest extends StatelessWidget {
//   const ChainsTest({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF4B352A),
//         foregroundColor: Colors.white,
//         title: Text(
//           "Chains Test ...",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       bottomNavigationBar: CurvedNavigationBar(items: [
//         Icon(
//           Icons.voice_chat,
//           size: 30,
//         ),
//
//         Icon(
//           Icons.voice_chat_outlined,
//           size: 30,
//         ),
//
//         Icon(
//           Icons.add_a_photo, //add_outlined
//           size: 30,
//         ),
//
//         Icon(
//           Icons.file_present,
//           size: 30,
//         ),
//
//         Icon(
//           Icons.settings_outlined, //person_2_outlined
//           size: 30,
//         ),
//
//       ]),
//     );
//   }
// }

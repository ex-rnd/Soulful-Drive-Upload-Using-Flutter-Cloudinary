// lib/screens/soulful.dart

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../screens/chains.dart';
import '../screens/rosters.dart';
import '../screens/spotlets.dart';
import '../screens/streams.dart';
import '../screens/vaults.dart';

class Soulful extends StatefulWidget {
  const Soulful({super.key});

  @override
  State<Soulful> createState() => _SoulfulState();
}

class _SoulfulState extends State<Soulful> {

  int _currentIndex = 0;

  final List<Widget> _screens = [
    Chains(),
    Streams(),
    Spotlets(),
    Vaults(),
    Rosters(),
  ];



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF3E8FF),
      child: SafeArea(
        top: false,
        left: false,
        right: false,

        child: Scaffold(
          backgroundColor: Color(0xFFF3E8FF),
          // appBar: AppBar(
          //   backgroundColor: Color(0xFF4B352A),
          //   foregroundColor: Colors.white,
          //   title: Text(
          //     "Chains Test ...",
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          // ),
          body:  _screens[_currentIndex],

          /////





          ////



          bottomNavigationBar: CurvedNavigationBar(
              color: Color(0xFF6F00FF),
              buttonBackgroundColor: Color(0xFF0B0B0B),
              backgroundColor: Colors.transparent,
              onTap: (value) {
                setState(() {
                  _currentIndex = value;
                });
              },


              items: [
                Icon(
                  _currentIndex == 0
                      ? Icons.voice_chat
                      : Icons.record_voice_over,
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
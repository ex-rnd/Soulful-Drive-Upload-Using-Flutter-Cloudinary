// lib/screens/vaults.dart

import 'package:flutter/material.dart';

class Vaults extends StatelessWidget {
  const Vaults({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 1. Custom header bar
          Material(
            elevation: 4,
            shadowColor: Colors.black.withValues(red: 0.3, blue: 0.3, green: 0.3),
            child: Container(
              color: Color(0xFF6F00FF),
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.archive_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: handle add‐box tap
                    },
                  ),
                  const Text(
                    'Files',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.auto_delete_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: handle add‐box tap
                    },
                  ),// keeps title centered
                ],
              ),
            ),
          ),

          // 2. Main content placeholder
          Expanded(
            child: Material(
              elevation: 50,
              shadowColor: Colors.black.withValues(red: 0.3, blue: 0.3, green: 0.3),
              child: Center(
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        'Vaults content goes here',
                        style: TextStyle(fontSize: 18),
                      ),



                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Optional in‐body row (if you don’t use the parent bottomNavBar)
          Container(
            color: Color(0xFF6F00FF),
            height: 20,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SizedBox(width: 0,),
                Text(
                    'Chains',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 4,),
                Text(
                    'Streams',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 3,),
                Text(
                    'Spotlets',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 3,),
                Text(
                    'Vaults',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 4,),
                Text(
                    'Rosters',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 0,),
              ],
            ),
          ),
          SizedBox(height: 12,),
        ],

      ),

    );






  }
}

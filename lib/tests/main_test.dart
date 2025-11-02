// lib/main.dart

import 'package:flutter/material.dart';
import 'package:soulful/screens/soulful.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soulful App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: Soulful(),
    );
  }
}


































//   // Real Part
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Soulful App',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       debugShowCheckedModeBanner: false,
//       // Your Refactored UI lives here:
//       home: Soulful(),
//     );
//   }
// }

// home: const NotificationUI(),


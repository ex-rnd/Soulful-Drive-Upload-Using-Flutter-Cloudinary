// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soulful/services/service_firebase.dart';
import 'package:soulful/views/home.dart';
import 'package:soulful/views/login.dart';
import 'package:soulful/views/signup.dart';
import 'package:soulful/views/upload_screen.dart';

import '../firebase_options.dart';
import 'package:soulful/firebase_options.dart';
// import 'package:soulful/screens/soulful.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soulful Drive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      routes:
      {
        // "/" : (context) => HomePage(),
        "/" : (context) => CheckUserLoggedIn(),
        "/home" : (context) => HomePage(),
        "/login" : (context) => LoginPage(),
        "/signup" : (context) => SignUpPage(),
        "/upload" : (context) => UploadArea(),
      },
    );
  }
}


class CheckUserLoggedIn extends StatefulWidget {
  const CheckUserLoggedIn({super.key});

  @override
  State<CheckUserLoggedIn> createState() => _CheckUserLoggedInState();
}

class _CheckUserLoggedInState extends State<CheckUserLoggedIn> {

  @override
  void initState() {
    AuthService().isLoggedIn().then(
            (value) {

          if (value) {
            Navigator.pushReplacementNamed(context, "/home");
          } else {
            Navigator.pushReplacementNamed(context, "/login");
          }

        }
    );



    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurple,
        ),
      ),
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


// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soulful/screens/Chains/chain_convos.dart';
import 'package:soulful/services/service_firebase.dart';
import '../firebase_options.dart';

import 'package:soulful/screens/soulful.dart';
import 'package:soulful/views/home.dart';
import 'package:soulful/accounts/signin.dart';
import 'package:soulful/accounts/signup.dart';
import 'package:soulful/views/upload_screen.dart';


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
      title: 'Soulful App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF6F00FF)),
      ),
      debugShowCheckedModeBanner: false,
      // App routes
      routes:
      {
        // "/" : (context) => HomePage(),
        "/" : (context) => CheckUserLoggedIn(),
        "/soulful" : (context) => Soulful(),
        "/home" : (context) => HomePage(),
        "/signin" : (context) => LoginPage(),
        "/signup" : (context) => SignUpPage(),
        "/upload" : (context) => UploadArea(),
        //"/convos" : (context) => ChainConvos(),
      },


      //

      //home: Soulful(),
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
            Navigator.pushReplacementNamed(context, "/soulful");
          } else {
            Navigator.pushReplacementNamed(context, "/signin");
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


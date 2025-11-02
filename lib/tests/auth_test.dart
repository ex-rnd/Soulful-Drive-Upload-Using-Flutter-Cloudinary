


import 'package:soulful/authorization/authorize.dart';

import 'package:appwrite/appwrite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:soulful/app_config.dart';
import 'package:soulful/firebase_options.dart';
import 'package:soulful/notification_service.dart';

// import 'package:soulful/screens/soulful.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService().initializeNotifications();
  Client client = Client().setEndpoint("https://cloud.appwrite.io/v1").setProject(AppConfig.projectId);
  Account account = Account(client);
  Databases databases = Databases(client);
  Storage storage = Storage(client);
  Functions functions = Functions(client);
  runApp(MyApp(
    account: account,
    databases: databases,
    storage: storage,
    functions: functions,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp(
      {super.key,
        required this.account,
        required this.databases,
        required this.storage,
        required this.functions
      });

  final Account account;
  final Databases databases;
  final Storage storage;
  final Functions functions;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soul Kiss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(
          account: account,
          databases: databases,
          storage: storage,
          functions: functions
      ),
      // Soulful()
    );
  }
}


// HomePage(
// account: account,
// databases: databases,
// storage: storage,
// functions: functions
// ),


import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new account - email, password
  Future<String> createAccountWithEmail(
      String name,
      String contact,
      String email,
      String password,
      ) async {
    try {
      // 1. Create user in Firebase Auth and grab the UID from the returned UserCredential
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;

      // 2. Write to Firestore under the new UID
      await _firestore.collection("spotters").doc(uid).set({
        "name": name,
        "uid": uid,
        "contact": contact,
        "email": email,
        "status": "Unavailable",
        "cackling": false,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      return "Account created successfully";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An unknown auth error occurred";
    } catch (e, st) {
      // catches any other errors (network, Firestore, etc.)
      log("Error in createAccountWithEmail: $e\n$st");
      return "Failed to create account: ${e.toString()}";
    }
  }








  // Login - email, password
  Future<String> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Login successful";
    } on FirebaseAuthException catch (e) {
      // Handle errors here
      return e.message.toString();
    }
  }

  // Logout
  Future<String> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return "Logout successful";
    } catch (e) {
      // Handle errors here
      return e.toString();
    }
  }


  // Is Logged In
  Future<bool> isLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  // // Set Status
  // Future<String> setStatus(String status) async {
  //   FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //   User? user = FirebaseAuth.instance.currentUser;
  //
  //   String appState = "Unavailable";
  //     if (AppLifecycleState.resumed == AppLifecycleState.resumed) {
  //       setStatus("Online"); return appState = "Online";
  //     } else if (AppLifecycleState.paused == AppLifecycleState.paused) {
  //       setStatus("Offline"); return appState = "Offline";
  //     } else if (AppLifecycleState.inactive == AppLifecycleState.inactive) {
  //       setStatus("Inactive"); return appState = "Inactive";
  //     } else if (AppLifecycleState.detached == AppLifecycleState.detached) {
  //       setStatus("Busy"); return appState = "Busy";
  //     }
  //
  //
  //   if (appState == "Online") {
  //     status = "Online";
  //   } else if (appState == "Offline") {
  //     status = "Offline";
  //   } else if (appState == "Inactive") {
  //     status = "Inactive";
  //   } else if (appState == "Busy") {
  //     status = "Busy";
  //   }
  //
  //   if (user != null) {
  //     try {
  //       await _firestore.collection("spotters").doc(user.uid).update({
  //         "status": status,
  //         "updatedAt": FieldValue.serverTimestamp(),
  //       });
  //       log("Status updated to $status for user ${user.uid}");
  //       return "Status updated to $status";
  //     } catch (e) {
  //       // Handle errors here
  //       log("Failed to update status: ${e.toString()}");
  //       return "Status update failed: ${e.toString()}";
  //     }
  //   }
  //   log("User not found");
  //   return "Status update failed: User not found";
  // }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_cloudinary_file_upload/services/cloudinary_service.dart';
import 'package:soulful/services/service_cloudinary.dart';

class DbService {
  User? user = FirebaseAuth.instance.currentUser;

  // save files links to firestore
  Future<void> saveUploadedFilesData(Map<String, String> data) async {
    return FirebaseFirestore.instance
        .collection("user-files")
        .doc(user!.uid)
        .collection("uploads")
        .doc()
        .set(data);
  }

  // read all uploaded files
  Stream<QuerySnapshot> readUploadedFiles() {
    return FirebaseFirestore.instance
        .collection("user-files")
        .doc(user!.uid)
        .collection("uploads")
        .snapshots();
  }

  // delete a specific document
  Future<bool> deleteFile(String docId, String publicId) async {
    // delete file from cloudinary
    final result = await deleteFromCloudinary(publicId);

    if (result) {
      await FirebaseFirestore.instance
          .collection("user-files")
          .doc(user!.uid)
          .collection("uploads")
          .doc(docId)
          .delete();
      return true;
    }
    return false;
  }
}


// import 'dart:developer';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:soulful/services/service_cloudinary.dart';
// import 'package:uuid/v1.dart';
//
// class DbService {
//
//   ///
//   ///
//   final _auth = FirebaseAuth.instance;
//   // Auto‐login constructor
//   DbService() {
//     _auth
//         .signInWithEmailAndPassword(
//       email: 'carrara@gmail.com',
//       password: '12345678',
//     )
//         .then((_) => log('Auto‐login successful: ${_auth.currentUser?.uid}'))
//         .catchError((e) => log('Auto‐login failed: $e'));
//   }
//
//
//
//
//
//   ///
//
//
//
//   // User
//   //User? user = FirebaseAuth.instance.currentUser;
//   // Always read the latest currentUser
//   User? get user => _auth.currentUser;
//
//
//   // Save files
//   Future<void> saveUploadedFilesData(Map<String, String> data) async {
//     try {
//       // Firestore
//       //final String uid = UuidV1().toString();
//       final uid = FirebaseAuth.instance.currentUser?.uid;
//       if (uid == null) final String uid = UuidV1().toString();
//         //throw StateError("User not authenticated");
//
//         return FirebaseFirestore.instance
//             .collection("user_files")
//             .doc(uid) //.doc(user!.uid)
//             .collection("uploads")
//             .doc()
//             .set({
//           ... data,
//           'created_at': FieldValue.serverTimestamp()
//         });
//
//
//     } catch (e) {
//       return log(e.toString());
//     }
//
//   }
//
//   // Read uploaded files
//   // Stream<QuerySnapshot> readUploadedFiles() {
//   //   try {
//   //     // Firestore
//   //     return FirebaseFirestore.instance
//   //         .collection("user_files")
//   //         .doc(user!.uid)
//   //         .collection("uploads")
//   //         .orderBy("created_at", descending: true)
//   //         .snapshots();
//   //   } catch (e) {
//   //     log(e.toString());
//   //     return const Stream.empty();
//   //   }
//   // }
//   //
//
//   // Read uploaded files
//   Stream<List<UploadedFile>> readUploadedFiles() {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) {
//       log("User not authenticated");
//       return Stream.value(<UploadedFile>[]);
//     }
//
//     return FirebaseFirestore.instance
//         .collection("user_files")
//         .doc(uid)
//         .collection("uploads")
//         .orderBy("createdAt", descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => UploadedFile.fromMap(doc.data(), doc.id))
//             .toList()
//     );
//
//
//   }
//
//   //
//
//
//   // Delete file
//   Future<bool> deleteFile(String docId, String publicId) async {
//     // Delete file from Firestore
//     await FirebaseFirestore.instance
//         .collection("user_files")
//         .doc(user!.uid)
//         .collection("uploads")
//         .doc(docId)
//         .delete();
//
//
//     // Delete file from Cloudinary
//     // await deleteFromCloudinary(publicId);
//
//
//
//     return true;
//
//     //bool result = true; // Assuming deleteFromCloudinary is implemented and returns a boolean
//
//     // if (result) {
//     //   await FirebaseFirestore.instance
//     //       .collection("user_files")
//     //       .doc(user!.uid)
//     //       .collection("uploads")
//     //       .doc(docId)
//     //       .delete();
//     //   return true;
//     // }
//     //return false;
//   }
//
// }
//
// class UploadedFile {
//   final String docId;
//   final String name;
//   final String url;
//   final String extension;
//
//   UploadedFile({
//     required this.docId,
//     required this.name,
//     required this.url,
//     required this.extension,
//   });
//
//   factory UploadedFile.fromMap(Map<String, dynamic> map, String docId) {
//     return UploadedFile(
//         docId: docId,
//         name: map['name'] as String,
//         url: map['url'] as String,
//         extension: map['extension'] as String
//     );
//   }
//
//
//
// }
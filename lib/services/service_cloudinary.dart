
// uploading files to cloudinary
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
//import 'package:flutter_cloudinary_file_upload/services/db_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:http/http.dart" as http;
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soulful/services/service_firestore.dart'; // For accessing device directories

Future<bool> uploadToCloudinary(FilePickerResult? filePickerResult) async {
  if (filePickerResult == null || filePickerResult.files.isEmpty) {
    print("No file selected!");
    return false;
  }

  File file = File(filePickerResult.files.single.path!);

  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

  // Create a MultipartRequest to upload the file
  var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");
  var request = http.MultipartRequest("POST", uri);

  // Read the file content as bytes
  var fileBytes = await file.readAsBytes();

  var multipartFile = http.MultipartFile.fromBytes(
    'file', // The form field name for the file
    fileBytes,
    filename: file.path.split("/").last, //The file name to send in the request
  );

  // Add the file part to the request
  request.files.add(multipartFile);

  request.fields['upload_preset'] = "soulful-bucket";
  request.fields['resource_type'] = "raw";

  // Send the request and await the response
  var response = await request.send();

  // Get the response as text
  var responseBody = await response.stream.bytesToString();

  // Print the response
  print(responseBody);

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(responseBody);
    Map<String, String> requiredData = {
      "name": filePickerResult.files.first.name,
      "id": jsonResponse["public_id"],
      "extension": filePickerResult.files.first.extension!,
      "size": jsonResponse["bytes"].toString(),
      "url": jsonResponse["secure_url"],
      "created_at": jsonResponse["created_at"],
    };

    await DbService().saveUploadedFilesData(requiredData);
    print("Upload successful!");
    return true;
  } else {
    print("Upload failed with status: ${response.statusCode}");
    return false;
  }
}

// delete specific file from cloudinary
Future<bool> deleteFromCloudinary(String publicId) async {
  // Cloudinary details
  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ??
      ''; // Replace with your Cloudinary cloud name
  String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  String apiSecret = dotenv.env['CLOUDINARY_SECRET_KEY'] ?? '';

  // Generate the timestamp
  int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  // Prepare the string for signature generation
  String toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';

  // Generate the signature using SHA1
  var bytes = utf8.encode(toSign);
  var digest = sha1.convert(bytes);
  String signature = digest.toString();
  // Prepare the request URL
  var uri =
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/destroy/');

  // Create the request
  var response = await http.post(
    uri,
    body: {
      'public_id': publicId,
      'timestamp': timestamp.toString(),
      'api_key': apiKey,
      'signature': signature,
    },
  );

  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    print(responseBody);
    if (responseBody['result'] == 'ok') {
      print("File deleted successfully.");
      return true;
    } else {
      print("Failed to delete the file.");
      return false;
    }
  } else {
    print(
        "Failed to delete the file, status: ${response.statusCode} : ${response.reasonPhrase}");
    return false;
  }
}

// download the user file inside the download folder
Future<bool> downloadFileFromCloudinary(String url, String fileName) async {
  try {
    // Request storage permission
    var status = await Permission.storage.request();
    var manageStatus = await Permission.manageExternalStorage.request();
    if (status == PermissionStatus.granted &&
        manageStatus == PermissionStatus.granted) {
      // The user has granted both permissions, so proceed
      print("Storage permissions granted");
    } else {
      // The user has permanently denied one or both permissions, so open the settings
      await openAppSettings();
    }

    // Get the Downloads directory
    Directory? downloadsDir = Directory('/storage/emulated/0/Download');
    if (!downloadsDir.existsSync()) {
      print("Downloads directory not found");
      return false;
    }

    // Create the file path
    String filePath = '${downloadsDir.path}/$fileName';

    // Make the HTTP GET request
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Write file to Downloads folder
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print("File downloaded successfully! Saved at: $filePath");
      return true;
    } else {
      print("Failed to download file. Status code: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("Error downloading file: $e");
    return false;
  }
}












//
//
// // Uploading soulful files
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
//
// import 'package:crypto/crypto.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:soulful/services/service_firestore.dart';
// import 'package:permission_handler/permission_handler.dart';
//
//
//
// Future<bool> uploadToCloudinary(FilePickerResult? filePickerResult) async {
//   try {
//     // Check if the user has selected a file
//     if (filePickerResult == null || filePickerResult.files.isEmpty) {
//       log('No file selected for upload.');
//       return false; // No file selected
//     }
//
//     File file = File(filePickerResult.files.single.path!);
//
//     final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
//     if (cloudName == null || cloudName.isEmpty) {
//       throw StateError('CLOUDINARY_CLOUD_NAME not set in .env');
//     }
//
//     //String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
//
//     // Multipart Request to Cloudinary
//     var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");
//     var request = http.MultipartRequest('POST', uri);
//
//     // Read the file contents
//     var fileBytes = await file.readAsBytes();
//
//     var multipartFile = http.MultipartFile.fromBytes(
//       'file', // The name of the field in the form data
//       fileBytes,
//       filename: file.path.split("/").last, // Use the original file name
//     );
//
//     request.files.add(multipartFile);
//
//     request.fields['upload_preset'] = "soulful-bucket";
//     request.fields['resource_type'] = "raw";
//
//     // Send the request
//     var response = await request.send();
//
//     //Get the response
//     var responseBody = await response.stream.bytesToString();
//
//     // Print the response for debugging
//     log('Response from Cloudinary: $responseBody');
//
//     // Check if the upload was successful
//     if (response.statusCode == 200) {
//
//       var jsonResponse = jsonDecode(responseBody);
//
//       Map<String, String> requiredData = {
//         "name" : filePickerResult.files.first.name, //jsonResponse['display_name'] ?? '',
//         "id" : jsonResponse['public_id'] ?? '',
//         "emotion" : "neutral",
//         "extension" : filePickerResult.files.first.extension ?? "",
//         "size" : jsonResponse['bytes'].toString(),
//         "url" : jsonResponse['secure_url'] ?? '',
//         "created_at" : jsonResponse['created_at'] ?? '',
//       };
//
//       await DbService().saveUploadedFilesData(requiredData);
//
//
//
//
//
//       log('File uploaded successfully to Cloudinary.');
//       return true; // Indicate success
//     } else {
//       log('Failed to upload file. Status code: ${response.statusCode}');
//       return false; // Indicate failure
//     }
//   } catch (e) {
//     log('Error uploading file: $e');
//     return false; // Indicate failure
//   }
//
// }
//
//
// // Delete file from Cloudinary
// Future<bool> deleteFromCloudinary(String publicId) async {
//   // Cloudinary details
//   String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ??
//       ''; // Replace with your Cloudinary cloud name
//   String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
//   String apiSecret = dotenv.env['CLOUDINARY_SECRET_KEY'] ?? '';
//
//   // Generate the timestamp
//   int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//
//   // Prepare the string for signature generation
//   String toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
//
//   // Generate the signature using SHA1
//   var bytes = utf8.encode(toSign);
//   var digest = sha1.convert(bytes);
//   String signature = digest.toString();
//   // Prepare the request URL
//   var uri =
//   Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/destroy/');
//
//   // Create the request
//   var response = await http.post(
//     uri,
//     body: {
//       'public_id': publicId,
//       'timestamp': timestamp.toString(),
//       'api_key': apiKey,
//       'signature': signature,
//     },
//   );
//
//   if (response.statusCode == 200) {
//     var responseBody = jsonDecode(response.body);
//     log(responseBody);
//     if (responseBody['result'] == 'ok') {
//       log("File deleted successfully.");
//       return true;
//     } else {
//       log("Failed to delete the file.");
//       return false;
//     }
//   } else {
//     log(
//         "Failed to delete the file, status: ${response.statusCode} : ${response.reasonPhrase}");
//     return false;
//   }
// }
//
//
// Future<bool?> downloadFileFromCloudinary(String url, String fileName) async {
//   try {
//
//     // Request storage permissions if necessary
//     var status = await Permission.storage.request();
//     var manageStatus = await Permission.manageExternalStorage.request();
//
//     // Check if the permissions are granted
//     if (status == PermissionStatus.granted || manageStatus == PermissionStatus.granted) {
//       log('Storage permissions granted.');
//       return true; // Permission granted
//     }
//     else {
//       log('Storage permissions denied.');
//       await openAppSettings(); // Open app settings to request permissions
//     }
//
//     // Downloads directory
//     Directory? downloadsDir = Directory('storage/emulated/0/Download');
//
//     if (!downloadsDir.existsSync()) {
//       log('Downloads directory does not exist. Creating it...');
//       return false; // Indicate failure
//     }
//
//     // Create the file path
//     String filePath = '${downloadsDir.path}/$fileName';
//
//     // Make HTTP GET request to download the file
//     var response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       // Write the file to the downloads directory
//       File file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);
//
//       log('File downloaded successfully to $filePath');
//     } else {
//       log('Failed to download file. Status code: ${response.statusCode}');
//       return false; // Indicate failure
//     }
//
//   } catch (e) {
//     log('Error downloading file: $e');
//     return false; // Indicate failure
//   }
// }
//
//
//
//

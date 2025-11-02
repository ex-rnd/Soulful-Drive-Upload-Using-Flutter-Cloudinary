// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:record/record.dart';
// import 'package:path/path.dart' as p;
//
// class CacklePage extends StatefulWidget {
//   const CacklePage({super.key});
//
//   @override
//   State<CacklePage> createState() => _CacklePageState();
// }
//
// class _CacklePageState extends State<CacklePage> {
//
//   final AudioRecorder audioRecorder = AudioRecorder();
//   final AudioPlayer audioPlayer = AudioPlayer();
//
//   String? recordingPath;
//   bool isRecording = false;
//   bool isPlaying = false;
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: _recordingButton(),
//       body: _buildUI(),
//     );
//   }
//
//   Widget _buildUI() {
//     return SizedBox(
//       width: MediaQuery.sizeOf(context).width,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           if (recordingPath != null) MaterialButton(
//             onPressed: () async {
//               if (audioPlayer.playing) {
//                 await audioPlayer.stop();
//                 setState(() {
//                   isPlaying = false;
//                 });
//               }
//               else {
//                 await audioPlayer.setFilePath(recordingPath!);
//
//                 await audioPlayer.setVolume(1.0);
//
//                 await audioPlayer.play();
//                 setState(() {
//                   isPlaying = true;
//                 });
//
//               }
//             },
//             color: Theme.of(context).colorScheme.primary,
//             child: Text(
//               isPlaying
//                   ? "Stop playing recording"
//                   : "Start playing recording",
//               style: const TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           if (recordingPath == null) const Text("No Recording Found"),
//
//         ],
//       ),
//     );
//
//   }
//
//   Widget _recordingButton() {
//     return FloatingActionButton(onPressed: () async {
//       if (isRecording) {
//         String? filePath = await audioRecorder.stop();
//         if (filePath != null) {
//           setState(() {
//             isRecording = false;
//             recordingPath = filePath;
//           });
//         }
//
//
//
//       }
//       else {
//         if (await audioRecorder.hasPermission()) {
//           final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
//           final String filePath = p.join(appDocumentsDir.path, "recording.wav");
//
//           //final dir = await getExternalStorageDirectory();
//           //final filePath = p.join(dir!.path, 'recording.mp3');
//
//           await audioRecorder.start(const RecordConfig(), path: filePath);
//
//
//           setState(() {
//             isRecording = true;
//             recordingPath = null;
//           });
//
//         }
//
//
//       }
//
//     },
//       child: Icon(
//           isRecording
//               ?Icons.stop
//               :Icons.mic
//       ),
//     );
//   }
//
//
//
//
// }

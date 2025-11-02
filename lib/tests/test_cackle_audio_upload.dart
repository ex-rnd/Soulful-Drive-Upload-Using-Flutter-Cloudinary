// lib/main.dart

import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:soulful/cackle_bubble.dart';
import 'package:soulful/services/service_cloudinary.dart';
import 'package:soulful/services/service_firestore.dart';

import 'firebase_options.dart';


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
      title: 'Audio WaveForms',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<UploadedFile> uploadedFiles = [];

  late final RecorderController recorderController;
  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;

  List<String> audioFiles = [];
  bool isLoading = true;

  late Directory appDirectory;

  @override
  void initState() {
    // TODO: implement initState
    _initializeControllers();
    //_getDir();
    //_setUpDirAndFiles();
    //_listenToFirestoreUploads();
    //_reloadAudioFiles();
    _setupFileListener();

    super.initState();
  }

  void _initializeControllers () {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  // Future<void> _reloadAudioFiles() async {
  //   final entries = appDirectory
  //       .listSync()
  //       .whereType<File>()
  //       .where((f) => f.path.endsWith('.wav'))
  //       .toList();
  //   entries.sort((a, b) => a.path.compareTo(b.path));
  //   setState(() {
  //     audioFiles = entries.map((f) => f.path).toList();
  //   });
  // }



  // void _getDir() async {
  //   //appDirectory = await getApplicationDocumentsDirectory();
  //   //path = "${appDirectory.path}/recording.wav";
  //
  //   appDirectory = await getApplicationCacheDirectory();
  //   path = "${appDirectory.path}/recording.wav";
  //
  //   isLoading = false;
  //
  //   setState(() {
  //
  //   });
  // }

  // Future<void> _setUpDirAndFiles() async {
  //   appDirectory = await getApplicationCacheDirectory();
  //   await _reloadAudioFiles();
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  // Future<void> _reloadAudioFiles() async {
  //   final entries = appDirectory
  //       .listSync()
  //       .whereType<File>()
  //       .where((f) => f.path.endsWith('.wav'))
  //       .toList();
  //
  //   entries.sort((a, b) {
  //     final aIdx = int.tryParse(
  //       a.path.split(Platform.pathSeparator).last.replaceAll(RegExp(r'[^0-9]'), '')
  //     ) ?? 0;
  //
  //     final bIdx = int.tryParse(
  //       b.path.split(Platform.pathSeparator).last.replaceAll(RegExp(r'[^0-9]'), '')
  //     ) ?? 0;
  //     return aIdx.compareTo(bIdx);
  //   });
  //
  //   audioFiles = entries.map((f) => f.path).toList();
  //
  // }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) {
      debugPrint("No file picked");
      return;
    }
    //
    final picked = File(result.files.single.path!);
    final nextIndex = audioFiles.length + 1;
    final newName   = 'audio$nextIndex.wav';
    final destPath  = '${appDirectory.path}/$newName';
    final destFile  = File(destPath);

    // 1) Copy the picked file into cache
    await picked.copy(destPath);

    // 2) Update your list and rebuild
    setState(() {
      audioFiles.add(destFile.path);
    });



    final didUpload = await uploadToCloudinary(result);
    if (!didUpload) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed – try again.")),
      );
      return;
    }

    //

    // 3) re-scan and rebuild the list, then redraw
    //await _reloadAudioFiles();
    setState(() {});
  }

  // Future<void> _listenToFirestoreUploads() async {
  //   DbService().readUploadedFiles().listen((files) async {
  //     for (var fileMeta in files) {
  //       final fileName = "${fileMeta.docId}.${fileMeta.extension}";
  //       final fullPath = "${appDirectory.path}/$fileName";
  //       final localFile = File(fullPath);
  //
  //       if (!await localFile.exists()) {
  //         final resp = await http.get(Uri.parse(fileMeta.url));
  //         if (resp.statusCode == 200) {
  //           await localFile.writeAsBytes(resp.bodyBytes);
  //         }
  //       }
  //
  //       if (!audioFiles.contains(fullPath)) {
  //         audioFiles.add(fullPath);
  //       }
  //     }
  //
  //     setState(() {
  //       uploadedFiles = files;
  //     });
  //   });
  // }

  Future<void> _setupFileListener() async {
    appDirectory = await getApplicationCacheDirectory();

    // ⇣⇣⇣ UNCOMMENT THIS TO WIPE CACHE ⇣⇣⇣
    // appDirectory
    //     .listSync()
    //     .whereType<File>()
    //     .forEach((f) => f.deleteSync());

    // now continue with your “scan existing” + Firestore listen…
    // Scanning existing files in the app directory
    final existing = appDirectory
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.wav'))
        .toList();

    audioFiles = existing.map((f) => f.path).toList();
    debugPrint('🔍 Found ${audioFiles.length} local .wav files on startup');


    setState(() {
      isLoading = false;
    });

    DbService()
        .readUploadedFiles().listen(_handleNewFirestoreFiles, onError: (err) {
      debugPrint("Error reading Firestore files: $err");
      }
    );
  }

  void _handleNewFirestoreFiles(List<UploadedFile> files) async {

    debugPrint('📨 Firestore sent ${files.length} items');


    for (var fileMeta in files) {
      final fileName = "${fileMeta.docId}.${fileMeta.extension}";
      final fullPath = "${appDirectory.path}/$fileName";
      final localFile = File(fullPath);

      localFile.exists().then((exists) async {
        debugPrint('— checking: $fileName; exists? $exists');

        if (!await localFile.exists()) {
          final resp = await http.get(Uri.parse(fileMeta.url));
          if (resp.statusCode == 200) {
            await localFile.writeAsBytes(resp.bodyBytes);
            debugPrint('✅ downloaded $fileName');

          } else {
            debugPrint("Failed to download file: ${fileMeta.url}");
            //continue; // skip adding to list

          }
        } else {
          debugPrint("File already exists: $fullPath");
        }

        if (!audioFiles.contains(fullPath)) {
          debugPrint('➕ adding to list: $fileName');
          setState(() {
            audioFiles.add(fullPath);
          });
        }
      });


    }


  }




  @override
  void dispose() {
    // TODO: implement dispose
    recorderController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    // if (isLoading) {
    //   return const Center(child: CircularProgressIndicator(),);
    // }

    debugPrint('👀 building UI with ${audioFiles.length} items');


    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(),),);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF252331),
      appBar: AppBar(
        backgroundColor: Color(0xFF252331),
        elevation: 1,
        centerTitle: true,
        shadowColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'SOUL',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.purpleAccent,
                )
            ),

            Text(
                'FUL',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF276bfd),
                )
            ),
          ],
        ),
      ),
      body:
      SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20,),

            Expanded(
                child: ListView.builder(
                    itemCount: audioFiles.length,
                    itemBuilder: (_, index) {
                      final filePath = audioFiles[index];

                      return WaveBubble(
                        key: ValueKey(filePath),
                        emotion: Emotion.happy,
                        path: audioFiles[index],
                        //index: index + 1,
                        isSender: false, //true,
                        width: MediaQuery.of(context).size.width,
                        appDirectory: appDirectory,

                        //isPlayable: true,
                      );


                    }
                )
            ),

            // if (musicFile != null)
            //   WaveBubble(
            //       key: ValueKey(musicFile),
            //       path: musicFile,
            //       isSender: false, //true,
            //       appDirectory: appDirectory
            //   ),

            SafeArea(
                child: GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF343145),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Text(
                      "Add Audio",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
            )

          ],
        )
        ,
      )

      ,
    );
  }
}


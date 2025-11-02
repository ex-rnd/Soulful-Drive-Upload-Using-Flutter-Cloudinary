// lib/main.dart

import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soulful/cackle_bubble.dart';

void main() {
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

  late final RecorderController recorderController;
  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;

  late Directory appDirectory;

  @override
  void initState() {
    // TODO: implement initState
    _initializeControllers();
    _getDir();
    super.initState();
  }

  void _initializeControllers () {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory.path}/recording.m4a";

    isLoading = false;

    setState(() {

    });
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      musicFile = result.files.single.path;
      setState(() {});
    }
    else {
      debugPrint("No file picked");
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
                  color: Colors.red,
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
      isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF276bfd),
        ),
      )
          : SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20,),

            Expanded(
                child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (_, index) {
                      return WaveBubble(
                          index: index + 1,
                          isSender: false, //true,
                          width: MediaQuery.of(context).size.width,
                          appDirectory: appDirectory
                      );
                    }
                )
            ),

            if (musicFile != null)
              WaveBubble(
                  path: musicFile,
                  isSender: false, //true,
                  appDirectory: appDirectory
              ),

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


import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:soulful/services/service_firebase.dart';
import 'package:soulful/services/service_firestore.dart';
import 'package:soulful/views/preview_image.dart';
import 'package:soulful/views/preview_video.dart';

import '../services/service_cloudinary.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FilePickerResult? _filePickerResult;

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      //type: FileType.any, // You can specify the type of files you want to pick
      allowMultiple: false,
      allowedExtensions: ["jpg", "jpeg", "png", "mp4"],
      type: FileType.custom
    );

    setState(() {
      _filePickerResult = result;
    });

    if (_filePickerResult != null) {
      Navigator.pushNamed(context, "/upload", arguments: _filePickerResult);
    }


  }

  List userUploadedFiles = [];

  //bool deleteResult = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Soulful Files"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(
                  context,
                  "/login"
              );
              //Navigator.pushNamed(context, "/login");
            },
          ),
        ],
      ),

      body: StreamBuilder(
        stream: DbService().readUploadedFiles(),
        builder: (context, snapshot) {
          // 1. Error state
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          // 2. Loading state
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // 3. We have data!
          final userUploadedFiles = snapshot.data!.docs;
          if (userUploadedFiles.isEmpty) {
            return Center(child: Text("No files uploaded yet."));
          }

          // 4. Build the grid with your real data
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: userUploadedFiles.length,
            itemBuilder: (context, index) {

              //final file = userUploadedFiles[index].data() as Map<String, dynamic>;
              final name = userUploadedFiles[index]['name'] as String;
              final ext = userUploadedFiles[index]['extension'] as String;
              final publicId = userUploadedFiles[index]['id'] as String;
              final fileUrl = userUploadedFiles[index]['url'] as String;

              //
              return GestureDetector(
                  onLongPress: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete file"),
                          content: const Text(
                              "Are you sure you want to delete?"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                      const SnackBar(
                                        content: Text("File deletion cancelled"),
                                      )
                                  );
                                },
                                child: Text("No")),
                            TextButton(
                                onPressed: () async {
                                  final bool deleteResult =
                                  await DbService().deleteFile(
                                      snapshot.data!.docs[index].id,
                                      publicId);
                                  // deleteResult = true;
                                  if (deleteResult) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text("File deleted"),
                                      ),

                                    );
                                  } else {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Error in deleting file."),
                                      ),
                                    );
                                  }
                                  Navigator.pop(context);
                                },
                                child: Text("Yes")),
                          ],
                        ));
                  },
                  onTap: () {
                    if (ext == "png" || ext == "jpg" || ext == "jpeg") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PreviewImage(url: fileUrl)));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PreviewVideo(videoUrl: fileUrl)));
                    }
                  },





              //
              child: Container(
                color: Colors.grey.shade300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                      (ext == "jpg" || ext == "jpeg" || ext == "png")
                      ?Image.network(
                          fileUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover
                      )
                      :Icon(Icons.movie),
                    ),
                    //const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        children: [
                          Icon(
                            (ext == "jpg" || ext == "jpeg" || ext == "png")
                                ? Icons.image
                                : Icons.movie,
                            size: 24,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child:
                          Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis
                            )
                          ),
                          IconButton(
                              onPressed: () async {
                                // Download the file
                                final downloadResult =
                                    await downloadFileFromCloudinary(
                                        fileUrl, name);

                                if (downloadResult == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("File downloaded successfully"),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Error in downloading file"),
                                    ),
                                  );
                                }


                              },
                              icon: Icon(
                                  Icons.download,
                                  size: 20,
                                  color: Colors.blue
                              )
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ));
            },
          );

        }
      ),

      floatingActionButton: FloatingActionButton(
          onPressed: ()
          {
            _openFilePicker();
          },
          child: Icon(Icons.add),

      ),


    );
  }
}

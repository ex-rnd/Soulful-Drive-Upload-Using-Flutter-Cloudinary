import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:soulful/services/service_cloudinary.dart';

class UploadArea extends StatefulWidget {
  const UploadArea({super.key});

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

class _UploadAreaState extends State<UploadArea> {
  @override
  Widget build(BuildContext context) {
    final selectedFile = ModalRoute.of(context)!.settings.arguments as FilePickerResult;


    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Files"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              readOnly: true,
              initialValue: selectedFile.files.first.name,
              decoration: InputDecoration(
                label: Text("Name")
              ),
            ),
            TextFormField(
              readOnly: true,
              initialValue: selectedFile.files.first.extension,
              decoration: InputDecoration(
                  label: Text("Extension")
              ),
            ),
            TextFormField(
              readOnly: true,
              initialValue: "${selectedFile.files.first.size} bytes",
              decoration: InputDecoration(
                  label: Text("Size")
              ),
            ),

            SizedBox(height: 20,),

            Row(

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () { Navigator.pop(context); } ,
                        child: Text("Cancel")
                    ),
                  ),

                SizedBox(width: 25,),

                Expanded(
                  child: ElevatedButton(
                      onPressed: () async {
                        final result = await uploadToCloudinary(selectedFile);

                        if (result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("File uploaded successfully!"))
                          );
                          Navigator.pop(context);
                          
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to upload file."))
                          );
                        }

                      } ,
                      child: Text("Upload")
                  ),
                ),





              ],
            )

          ],
        ),
      ),
      
    );
  }
}

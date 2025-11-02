

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '/services/service_firebase.dart';

class ChainConvos extends StatefulWidget {
  const ChainConvos({super.key, required this.spotterMap, required this.convoChainId});
  final Map<String, dynamic>? spotterMap;
  final String? convoChainId;


  @override
  State<ChainConvos> createState() => _ChainConvosState();
}

class _ChainConvosState extends State<ChainConvos> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //AuthService().setStatus("Online");
    setCackling(true);
  }

  void setCackling(bool state) async {
    log(_auth.currentUser?.uid ?? "No user logged in");
    await _firestore.collection("spotters")
        .doc(_auth.currentUser?.uid)
        .update({
      "cackling": state,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setCackling(true);
    } else if (state == AppLifecycleState.paused) {
      setCackling(false);
    }
  }

  final TextEditingController _cackle = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery)
        .then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
     }
    );
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int istatus = 1;

    await _firestore
        .collection('convos')
        .doc(widget.convoChainId)
        .collection('cackles')
        .doc(fileName)
        .set(
            {
              "sendby": _auth.currentUser?.uid,
              "cackle": "",
              "type": "img",
              "time": FieldValue.serverTimestamp(),
            }
    );

    var ref = FirebaseStorage.instance
        .ref()
        .child("imageCackles")
        .child("$fileName.jpg");

    var uploadTask = await ref
        .putFile(imageFile!)
        .catchError((error) async {
          await _firestore
              .collection('convos')
              .doc(widget.convoChainId.toString())
              .collection('cackles')
              .doc(fileName)
              .delete();

          istatus = 0;
    });

    if (istatus == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('convos')
          .doc(widget.convoChainId)
          .collection('cackles')
          .doc(fileName)
          .update({
            "cackle": imageUrl,
          });

      log("Image uploaded successfully: $imageUrl");

      // setState(() {
      //   imageFile = null;
      // });
    }






  }

  void onSendCackle() async {
    if (_cackle.text.trim().isNotEmpty) {

      Map<String, dynamic> cackles = {
        "sendby": _auth.currentUser?.uid,
        "cackle": _cackle.text.trim(),
        "type": "cackle",
        "time": FieldValue.serverTimestamp(),
      };

      log("Sending cackle: ${_auth.currentUser?.uid}");



      _cackle.clear();


      await _firestore
          .collection('convos')
          .doc(widget.convoChainId)
          .collection('cackles')
          .add(cackles);


    }

    else {
      log("Empty cackle, not sending.");
    }



  }
  
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    _cackle.dispose();
    setCackling(false);
    super.dispose();
  }






  @override
  Widget build(BuildContext context) {
    final spotterMap   = widget.spotterMap;
    final convoChainId = widget.convoChainId;

    final size = MediaQuery.of(context).size;

    return Container(
      color: Color(0xFFF3E8FF),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Scaffold(
          appBar: AppBar(
            title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _firestore.collection("spotters").doc(spotterMap?['uid']).snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // 2. Error state
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }





                  if (snapshot.data != null) {

                    log("Spotter data: ${snapshot.data!.data()}");

                    final doc = snapshot.data!;
                    final name = doc.get('name') as String? ?? '';
                    final status = doc.get('status') as String? ?? '';
                    final cackling = doc.get('cackling') as bool? ?? false;

                    return Container(
                      child: Column(
                        children: [
                          Text(name), //spotterMap?['name']),
                          Text(
                            (cackling & (status == "Online")) ? "Online : Cackling" : "Offline : Chilling",
                            //status, //spotterMap?['status'], //status, //snapshot.data!, //spotterMap?['status'], //snapshot.data!
                            style:
                            (cackling & (status == "Online"))
                                ? TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.greenAccent)
                                : TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                          // Text(
                          //   (cackling & (status == "Online")) ? "Cackling" : "Quiet, spotter",
                          //   style: TextStyle(fontSize: 8, color: Colors.green),
                          // ),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                }
            ),
          ),

          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Color(0xFFF3E8FF),
                  height: size.height / 1.25,
                  width: size.width,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('convos')
                          .doc(convoChainId)
                          .collection('cackles')
                          .orderBy("time", descending: false)
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return ListView.builder(
                        itemCount: snapshot.data?.docs.length ?? 0,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!
                                        .docs[index]
                                        .data() as Map<String, dynamic>;
                          return cackles(size, map, context);
                                        }
                        );
                      }
                  ),
                ),

                Container(
                  height: size.height / 10,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height/12,
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: size.height/17,
                          width: size.width/1.3,
                          child: TextField(
                            controller: _cackle,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  onPressed: () => getImage(),
                                  icon: Icon(Icons.photo),
                              ),
                              hintText: "Cackle here ...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              )
                            ),
                          ),
                        ),

                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: onSendCackle,
                        ),


                      ],
                    ),
                  ),
                )


              ],
            ),
          ),




        ),
      ),
    );
  }



  //// Extra widgets and classes
  Widget cackles(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "cackle"
        ? Container(
      width: size.width,
      alignment: map['sendby'] == widget.spotterMap?['uid']
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: map['sendby'] == widget.spotterMap?['uid']
          ? Colors.blue
          : Colors.green,
        ),
        child: Text(
          map['cackle'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    )
        : Container(
      height: size.height / 2.5,
      width: size.width,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      alignment: map['sendby'] == widget.spotterMap?['uid']
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ShowImage(
              imageUrl: map['imageCackle'],
            ),
          ),
        ),
        child: Container(
          height: size.height / 2.5,
          width: size.width / 2,
          decoration: BoxDecoration(border: Border.all()),
          alignment: map['imageCackle'] != "" ? null : Alignment.center,
          child: map['imageCackle'] != ""
              ? Image.network(
            map['imageCackle'],
            fit: BoxFit.cover,
          )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

//
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
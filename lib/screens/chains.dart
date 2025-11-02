// lib/screens/chains.dart

import 'dart:developer';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:soulful/screens/Chains/chain_convos.dart';

import '../services/service_firebase.dart';

class Chains extends StatefulWidget {
  const Chains({super.key});

  @override
  State<Chains> createState() => _ChainsState();
}

class _ChainsState extends State<Chains> with WidgetsBindingObserver {

  Map<String, dynamic>? spotterMap;
  bool isLoading = false;


  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //didChangeAppLifecycleState(AppLifecycleState.resumed);
    setStatus("Online");
    }

  void setStatus(String status) async {
    await _firestore.collection("spotters")
        .doc(_auth.currentUser?.uid)
        .update({
            "status": status,
    });
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus("Online");
    } else if (state == AppLifecycleState.paused) {
      setStatus("Offline");
    } else if (state == AppLifecycleState.inactive) {
      setStatus("Unavailable");
    } else if (state == AppLifecycleState.detached) {
      setStatus("Busy");
    }
  }








  String convoChainId (String spotter1, String spotter2) {

    final comparison = spotter1.toLowerCase().compareTo(spotter2.toLowerCase());

    if (comparison <= 0) {
      var tempspotter1 = '${spotter1}_$spotter2'.toString();
      log(tempspotter1);
      return tempspotter1;
    } else {
      var tempspotter2 = '${spotter2}_$spotter1'.toString();
      log(tempspotter2);
      return tempspotter2;
    }

  }


  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    await _firestore
        .collection('spotters')
        .where("email", isEqualTo: _search.text.trim())
        .get()
        .then((value) {
          setState(() {
            spotterMap = value.docs[0].data();
            isLoading = false;
          });

          log(spotterMap.toString());

    }
    )


    ;

  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    setStatus("Offline");
    //didChangeAppLifecycleState(AppLifecycleState.detached);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: isLoading
      ? Center(
        child: Container(
          height: size.height / 20,
          width: size.width / 20,
        ),

      )
      : Column(
        children: [
          // 1. Custom header bar
          Material(
            elevation: 4,
            shadowColor: Colors.black.withValues(red: 0.3, blue: 0.3, green: 0.3),
            child: Container(
              color: Color(0xFF6F00FF),
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_box_outlined, color: Colors.white),
                    onPressed: () async {
                      // TODO: handle add‐box tap
                    },
                  ),
                  const Text(
                    'Convos',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_search_outlined, color: Colors.white),
                    onPressed: () async {
                      // TODO: handle add‐box tap
                      await AuthService().logout();
                      Navigator.pushReplacementNamed(
                          context,
                          "/signin"
                      );
                    },
                  ),// keeps title centered
                ],
              ),
            ),
          ),

          // 2. Main content placeholder
          Expanded(
            child: Material(
              elevation: 50,
              shadowColor: Colors.black.withValues(red: 0.3, blue: 0.3, green: 0.3),
              child: Center(
                child: Container(
                  child: Column(
                    children: [
                      // Text(
                      //   'Chains content goes here',
                      //   style: TextStyle(fontSize: 18),
                      // ),

                      //SizedBox(height: size.height/20,),
                      SizedBox(height: size.height/200,),

                      Container(
                        height: size.height/30,
                        width: size.width,
                        alignment: Alignment.center,

                        child: Container(
                          height: size.height/30,
                          width: size.width / 1.2,
                          child: TextField(
                            controller: _search,
                            decoration: InputDecoration(
                              hintText: "Search a spotter",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height/200,),

                      Container(
                        height: size.height/40,
                        width: size.width / 4.5,
                        child: ElevatedButton(
                            onPressed: onSearch //() {
                              //onSearch();
                              //},
                          ,
                            child: Text(
                                "Search",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            )
                        ),
                      ),

                      SizedBox(height: size.height/60,),

                      spotterMap != null
                      ? ListTile(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder:
                          (_) => ChainConvos(
                            spotterMap: spotterMap,
                            convoChainId: convoChainId.toString(),
                          )
                          )
                        ),
                        leading: Icon(
                          Icons.account_box,
                          color: Colors.black,
                        ),
                        title: Text(
                            spotterMap?['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(spotterMap?['email']),
                        trailing: Icon(
                          Icons.chat,
                          color: Colors.black,
                        ),

                      )
                      : Container(

                      ),



                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Optional in‐body row (if you don’t use the parent bottomNavBar)
          Container(
            color: Color(0xFF6F00FF),
            height: 20,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SizedBox(width: 0,),
                Text(
                    'Chains',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 4,),
                Text(
                    'Streams',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 3,),
                Text(
                    'Spotlets',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 3,),
                Text(
                    'Vaults',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 4,),
                Text(
                    'Rosters',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 0,),
              ],
            ),
          ),
          ColoredBox(
              color: Color(0xFF00BFFF),
              child: SizedBox(height: 12,)),
        ],

      ),

    );






  }
}








// Version 0

// Widget build(BuildContext context) {
//   return Center(
//     child: Text(
//       "Chains",
//       style: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold
//       ),
//     ),
//   );
// }
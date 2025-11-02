

import 'dart:io' as io;

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart';
import '../app_config.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
        required this.account,
        required this.databases,
        required this.storage,
        required this.functions});

  final Account account;
  final Databases databases;
  final Storage storage;
  final Functions functions;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  models.User? loggedInUser;
  List<models.Document> tasks = [];
  String? imagePath;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    tasks = await getTasks();
    setState(() {});
  }

  Future<void> refreshUserState() async {
    final user = await widget.account.get();
    setState(() {
      loggedInUser = user;
    });
  }

  Future<void> login(String email, String password) async {
    await widget.account.createEmailPasswordSession(email: email, password: password);
    final user = await widget.account.get();
    setState(() {
      loggedInUser = user;
    });

    final fcmToken = await FirebaseMessaging.instance.getToken();
    await widget.account.createPushTarget(
      targetId: ID.unique(),
      identifier: fcmToken!,
      providerId: AppConfig.providerId,
    );

    // Force fresh state update
    await refreshUserState();


    setState(() {
      loggedInUser = user;
    });
  }

  Future<void> register(String email, String password, String name) async {
    await widget.account.create(userId: ID.unique(), email: email, password: password, name: name);
    
    await login(email, password);
  }



  Future<void> logout() async {
    try {

      await widget.account.deleteSession(sessionId: 'current');
      setState(() {
        loggedInUser = null;
      });
    } on AppwriteException catch (e) {
      debugPrint('Error: $e');
    }

  }

  Future<bool> createTask(String title, String description) async {
    try {
      final newTask = await widget.databases.createDocument(
        databaseId: AppConfig.databaseId,
        collectionId: AppConfig.databaseCollectionId,
        documentId: ID.unique(),
        data: {
          'cackle': title,
          'url': description,
          'roasted': false,
        },
      );

      setState(() {
        tasks.add(newTask);
      });
      return true;
    } on AppwriteException catch (e) {
      debugPrint('Error: $e.message');
      return false;
    }
  }

  Future<List<models.Document>> getTasks() async {
    try {
      final response = await widget.databases.listDocuments(
        databaseId: AppConfig.databaseId,
        collectionId: AppConfig.databaseCollectionId,
      );
      return response.documents;
    } on AppwriteException catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }

  Future<bool> updateTask(String taskID, bool completed) async {
    try {
      final updatedTask = await widget.databases.updateDocument(
          databaseId: AppConfig.databaseId,
          collectionId: AppConfig.databaseCollectionId,
          documentId: taskID,
          data: {
            'roasted': completed,
          });

      final index = tasks.indexWhere((task) => task.$id == taskID);

      if (index != -1) {
        setState(() {
          tasks[index] = updatedTask;
        });
      }
      return true;
    } on AppwriteException catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await widget.databases.deleteDocument(
        databaseId: AppConfig.databaseId,
        collectionId: AppConfig.databaseCollectionId,
        documentId: taskId,
      );
      return true;
    } on AppwriteException catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  Future<XFile> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    return pickedFile!;
  }

  Future<bool> uploadImage() async {
    final file = await pickImage(ImageSource.gallery);

    try {
      await widget.storage.createFile(
        bucketId: AppConfig.storageBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path),
      );
      setState(() {
        imagePath = file.path;
      });
      return true;
    } on AppwriteException catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }


  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                await uploadImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await uploadImage();
              },
            ),
          ],
        );
      },
    );
  }






    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6F00FF),
      appBar: AppBar(
        backgroundColor: Color(0xFF6F00FF), // 0xFF6F00FF
        foregroundColor: Colors.white,
        centerTitle: true,

        title: ClipOval(
          child: Image.asset('assets/images/soulful_logo.png',
            width: 50,
            height: 50,
            //fit: BoxFit.cover,
          ),
        ),

        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //
                  const SizedBox(height: 2.0),
                  Text(
                    "Soulful ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),

                  // Inserted image before the login status text
                  InkWell(
                    // InkWell gives you a ripple effect over Material
                    borderRadius: BorderRadius.circular(100),
                    onTap: () => _showImageSourceSheet(context),

                    child: CircleAvatar(
                        radius: 50,
                        child: imagePath == null
                            ? const Icon(Icons.person)
                            : ClipOval(
                          child: Image.file(
                            io.File(imagePath!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ),

                  const SizedBox(height: 16.0),

                  Text(loggedInUser != null ? 'Logged in as ${loggedInUser!.name}' : 'Not logged in'),
                  const SizedBox(height: 16.0),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                 ]
                ),


                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          register(emailController.text, passwordController.text, nameController.text);
                        },
                        child: const Text('Register'),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          login(emailController.text, passwordController.text);
                        },
                        child: const Text('Login'),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          logout();
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                  //const SizedBox(height: 24.0),
                  const SizedBox(height: 8.0),

                  const Center(
                    child: Text(
                      "Database Operations",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: tasks.isEmpty
                        ? const Center(
                      child: Text("No tasks yet"),
                    )
                        : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Dismissible(
                          key: Key(task.$id),
                          onDismissed: (_) => deleteTask(task.$id),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: CheckboxListTile(
                            title: Text(task.data['cackle']),
                            subtitle: Text(task.data['url']),
                            value: task.data['roasted'] as bool,
                            onChanged: (value) {
                              if (value != null) {
                                updateTask(task.$id, value);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Task'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                          createTask(titleController.text, descriptionController.text);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
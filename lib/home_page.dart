import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_learning/create_user.dart';
import 'package:firebase_learning/upload_files.dart';
import 'package:firebase_learning/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'download_files.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final userLoggedIn = auth.FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello ${userLoggedIn.email}'),
        actions: [
          IconButton(
            onPressed: () => auth.FirebaseAuth.instance.signOut(),
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          //Read all datas in collection
          child: StreamBuilder<List<User>>(
              stream: readUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final users = snapshot.data!;
                  return ListView(
                    children:
                        users.map((user) => buildUser(context, user)).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              })

          //Read a data in collection with a specified doc
          // child: FutureBuilder<User?>(
          //     future: readUser(),
          //     builder: (context, snapshot) {
          //       if (snapshot.hasData) {
          //         final user = snapshot.data;
          //
          //         return user == null
          //             ? Center(child: Text('No User'))
          //             : buildUser(user);
          //       } else if (snapshot.hasError) {
          //         return Text('Error: ${snapshot.error}');
          //       } else {
          //         return CircularProgressIndicator();
          //       }
          //     })
          ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateUserPage()));
            },
            child: Icon(Icons.add),
          ),
          SizedBox(width: 16.0),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DownloadFilesPage()));
            },
            child: Icon(Icons.file_download),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UploadFilesPage()));
            },
            child: Icon(Icons.file_upload),
          ),
          // SizedBox(width: 16),
          // FloatingActionButton(
          //   onPressed: () {
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => NotificationPage()));
          //   },
          //   child: Icon(Icons.message),
          // )
        ],
      ),
    );
  }

  //Create widget to display user row with 2 options: update and delete
  Widget buildUser(BuildContext context, User user) => ListTile(
        leading: CircleAvatar(child: Text('${user.age}')),
        title: Text(user.name),
        subtitle: Text(user.birthday.toIso8601String()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                final updatedUser = await editUserDialog(context, user);
                if (updatedUser != null) {
                  final docUser = FirebaseFirestore.instance
                      .collection('users')
                      .doc(updatedUser.id);
                  docUser.update({
                    'name': updatedUser.name,
                    'age': updatedUser.age,
                    'birthday': updatedUser.birthday,
                  });

                  Fluttertoast.showToast(
                    msg: 'Update User Successfully',
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.lightGreen,
                    textColor: Colors.white,
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text(
                              'Are you sure you want to delete this user?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () {
                                final docUser = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.id);
                                docUser.delete();
                                Fluttertoast.showToast(
                                  msg: 'Delete User Successfully',
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.lightGreen,
                                  textColor: Colors.white,
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ));
              },
            ),
          ],
        ),
      );

  //Read all datas in collection
  Stream<List<User>> readUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());
  }

  //Read a data in collection with a specified doc
  Future<User?> readUser() async {
    final docUser = FirebaseFirestore.instance
        .collection('users')
        .doc('SpNNFBAdMzKw4SVkSCFI');
    final snapshot = await docUser.get();

    if (snapshot.exists) {
      return User.fromJson(snapshot.data()!);
    }
  }

  Future<User?> editUserDialog(BuildContext context, User user) async {
    //Specify initialized contents inside text editing controller
    TextEditingController nameController =
        TextEditingController(text: user.name);
    TextEditingController ageController =
        TextEditingController(text: user.age.toString());
    TextEditingController birthdayController =
        TextEditingController(text: user.birthday.toIso8601String());

    return showDialog<User>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: birthdayController,
                decoration: InputDecoration(labelText: 'Birthday'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final updatedUser = User(
                  id: user.id,
                  name: nameController.text,
                  age: int.parse(ageController.text),
                  birthday: DateTime.parse(birthdayController.text),
                );
                Navigator.of(context).pop(
                    updatedUser); //pass back to current context of updatedUser
              },
            ),
          ],
        );
      },
    );
  }
}

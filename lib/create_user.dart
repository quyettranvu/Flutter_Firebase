import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_learning/user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({Key? key}) : super(key: key);

  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final controllerName = TextEditingController();
  final controllerAge = TextEditingController();
  final controllerDateTime = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add User'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: controllerName,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: controllerAge,
                decoration: InputDecoration(
                  labelText: 'Age',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: controllerDateTime,
                decoration: InputDecoration(
                  labelText: 'Birthday (yyyy-mm-dd)',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final user = User(
                    name: controllerName.text,
                    age: int.parse(controllerAge.text),
                    birthday: DateTime.parse(controllerDateTime.text),
                  );

                  await createUser(user);

                  //reload to see effects
                  Fluttertoast.showToast(
                    msg: 'Add User Successfully',
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.lightGreen,
                    textColor: Colors.white,
                  );

                  //reset after setting successfully
                  controllerName.clear();
                  controllerAge.clear();
                  controllerDateTime.clear();

                  Navigator.pop(context);
                },
                child: Text('Save'),
              )
            ],
          ),
        ),
      );
  }

  Future createUser(User user) async {
    //Reference to document(if not specify name of id in doc then it will generate autimatically
    final docUser = FirebaseFirestore.instance.collection('users').doc();

    user.id = docUser.id;

    final jsonValue = user.toJson();    //Create document and write data to Firebase DB
    await docUser.set(jsonValue);
  }
}

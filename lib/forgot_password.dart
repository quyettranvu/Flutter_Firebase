import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'main.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.lightBlueAccent,
      elevation: 0,
      title: Text('Reset Password'),
    ),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Write an email to reset your password',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: 'Email'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                            ? 'Enter a valid email'
                          : null,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: ResetPassword,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50)
                ),
                icon: Icon(Icons.email_outlined),
                label: Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 24),
                )),
          ],
        )
      )
    )
  );

  Future ResetPassword() async{
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(context: context,
        builder: (context) => Center(child: CircularProgressIndicator()));

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim());

      //pops all the screens from the navigation stack until you reach the first screen
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: '${e.message}',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      Navigator.of(context).pop();
    }
  }

}

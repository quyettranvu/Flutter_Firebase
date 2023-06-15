import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'forgot_password.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginPage({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(height: 50.0),
        Image.asset('images/flutter_firebase.jpg'),
        TextField(
          controller: emailController,
          cursorColor: Colors.white,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Email',
          ),
        ),
        SizedBox(height: 16.0),
        TextField(
          controller: passwordController,
          cursorColor: Colors.white,
          textInputAction: TextInputAction.next,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
          ),
        ),
        SizedBox(height: 16.0),
        ElevatedButton.icon(
            onPressed: SignIn,
            icon: Icon(Icons.login, size: 30),
            label: Text(
              'Login',
              style: TextStyle(fontSize: 24),
            )),
        SizedBox(height: 16.0),
        GestureDetector(
            child: Text('Forgot Password?',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 20,
                )),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ForgotPasswordPage())
            );
          },
        ),
        RichText(
          text: TextSpan(
            //the .. operator is a shorthand way of chaining method calls in Dart.
            //allow to create a new TapGestureRecognizer object and immediately set its onTap property in one statement, without having to create a separate variable for the gesture recognizer.
            style: TextStyle(color: Colors.black, fontSize: 20),
            text: 'No accounts? ',
            children: [
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = widget.onClickedSignUp,
                text: 'Sign Up',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ]),
    ));
  }

  Future SignIn() async {
    //Loading
    showDialog(
        context: context,
        barrierDismissible: false,
        //not allowing user to tap outside to turn off dialog
        builder: (context) => Center(child: CircularProgressIndicator()));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: '${e.message}',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    //pops all the screens from the navigation stack until you reach the first screen
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}

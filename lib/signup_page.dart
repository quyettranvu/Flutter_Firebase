import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'main.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onClickedLogin;

  const SignUpPage({
    Key? key,
    required this.onClickedLogin,
  }) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(height: 50.0),
          Image.asset('images/flutter_firebase.jpg'),
          TextFormField(
            controller: emailController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Email',
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (email) =>
                email != null && !EmailValidator.validate(email)
                    ? 'Enter a valid email'
                    : null,
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => value != null && value.length < 6
                ? 'Enter min 6 characters'
                : null,
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: confirmPasswordController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.done,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Confirm Password',
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              } else if (value != passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          ElevatedButton.icon(
              onPressed: SignUp,
              icon: Icon(Icons.login, size: 30),
              label: Text(
                'Sign Up',
                style: TextStyle(fontSize: 24),
              )),
          SizedBox(height: 16.0),
          RichText(
            text: TextSpan(
              //the .. operator is a shorthand way of chaining method calls in Dart.
              //allow to create a new TapGestureRecognizer object and immediately set its onTap property in one statement, without having to create a separate variable for the gesture recognizer.
              style: TextStyle(color: Colors.black, fontSize: 20),
              text: 'Already have an account? ',
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onClickedLogin,
                  text: 'Login',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    ));
  }

  Future SignUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    //Loading
    showDialog(
        context: context,
        barrierDismissible: false,
        //not allowing user to tap outside to turn off dialog
        builder: (context) => Center(child: CircularProgressIndicator()));

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
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

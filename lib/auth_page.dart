import 'package:firebase_learning/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin
      ? LoginPage(onClickedSignUp: toggle)
      : SignUpPage(onClickedLogin: toggle);

  void toggle() =>setState(() => isLogin = !isLogin);
}

import 'dart:async';
import 'package:ancient_language_translator/login.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      checkUserLogin();
    });
  }

  Future<void> checkUserLogin() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is already logged in, navigate to home screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      // User is not logged in, navigate to login screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/icon.png"),
      ),
    );
  }
}

import 'package:ancient_language_translator/login.dart';
import 'package:ancient_language_translator/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signUp() async {
    try {
      if (passwordController.text != confirmPasswordController.text) {
        _showDialog("Error", "Passwords do not match");
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      UserCredential login = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      await saveUserData(userCredential.user!.uid);

      print("User signed up: ${userCredential.user?.uid}");

      _showDialog2("Success", "User signed up successfully!");

      // Additional actions after successful signup

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showDialog("Error", "The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        _showDialog("Error", "The account already exists for that email.");
      } else {
        _showDialog("Error", "Error: ${e.message}");
      }
    } catch (e) {
      _showDialog("Error", "Error: $e");
    }
  }

  Future<void> saveUserData(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': fullNameController.text,
        'email': emailController.text,
      });
    } catch (e) {
      _showDialog("Error", "Error: $e");
      print('Error saving user data: $e');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDialog2(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/download2.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.017),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.18,
                      height: MediaQuery.of(context).size.width * 0.18,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        image: DecorationImage(
                          image: AssetImage('assets/icon2.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  Text(
                    "Signup",
                    style: TextStyle(
                      color: Color(0xff101828),
                      fontSize: MediaQuery.of(context).size.height * 0.020,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Satoshi',
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: 2.0,
                      color: Colors.brown,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Text(
                    "Full Name",
                    style: TextStyle(
                      color: Color(0xff344054),
                      fontSize: MediaQuery.of(context).size.height * 0.015,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi',
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 0.5),
                      ),
                      child: TextField(
                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.015),
                        controller: fullNameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixText: "",
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Text(
                    "Email",
                    style: TextStyle(
                      color: Color(0xff344054),
                      fontSize: MediaQuery.of(context).size.height * 0.015,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi',
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 0.5),
                      ),
                      child: TextField(
                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.015),
                        controller: emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixText: "",
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Text(
                    "Password",
                    style: TextStyle(
                      color: Color(0xff344054),
                      fontSize: MediaQuery.of(context).size.height * 0.015,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi',
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 0.5),
                      ),
                      child: TextField(
                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.015),
                        controller: passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixText: "",
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: _obscureText ? Colors.grey : Colors.black,

                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Text(
                    "Re-enter Password",
                    style: TextStyle(
                      color: Color(0xff344054),
                      fontSize: MediaQuery.of(context).size.height * 0.015,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi',
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 0.5),
                      ),
                      child: TextField(
                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.015),
                        controller: confirmPasswordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixText: "",
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: _obscureText ? Colors.grey : Colors.black,

                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFdeb887),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "SignUp",
                          style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: MediaQuery.of(context).size.height * 0.018,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Satoshi',
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        onPressed: _signUp,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Color(0xff101828),
                          fontSize: MediaQuery.of(context).size.height * 0.015,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Satoshi',
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 0),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xff101828),
                            fontSize: MediaQuery.of(context).size.height * 0.017,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Satoshi',
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

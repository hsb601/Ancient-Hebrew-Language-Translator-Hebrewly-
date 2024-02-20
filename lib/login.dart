import 'package:ancient_language_translator/main.dart';
import 'package:ancient_language_translator/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
   LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;

  // Declare a GlobalKey
  final GlobalKey<State> _keyLoader = GlobalKey<State>();

  void signUserIn() async {
    // show loading circle

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Update user data in Firestore
      updateUserFirestoreData();

      // pop the loading circle
      //Navigator.of(_keyLoader.currentContext!).pop(); // Dismiss the dialog
      showLoginSuccessfulDialog();
    } on FirebaseAuthException catch (e) {
      if (emailController.text.isEmpty) {
        // Show pop-up indicating empty email field
        showEmptyFieldDialog(context, 'email');
      } else if (passwordController.text.isEmpty) {
        // Show pop-up indicating empty password field
        showEmptyFieldDialog(context, 'password');
      }
      else if (e.code =='invalid-email'){
        _showDialog("Invalid email", "${e.code}");

      }
    else if (e.code == 'invalid-credential') {
    _showDialog("Invalid Credentials", "${e.code}");
    }
      else {
        _showDialog("Invalid Credentials", "Code: ${e.code}, Message: ${e.message}");
        print('Code: ${e.code}');
        print('Message: ${e.message}');
      }
    }
  }
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Show success message or navigate to a success screen
      _showDialog("Password Reset Email Sent", "Check your email to reset your password.");
    } on FirebaseAuthException catch (e) {
      // Handle errors
      print('Error sending password reset email: ${e.message}');
      _showDialog("Error", "Failed to send password reset email. ${e.code}");
    }
  }

  void updateUserFirestoreData() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // You can update the necessary fields here
      // For example, if you have a 'lastLogin' field:
      await userDocRef.update({'lastLogin': DateTime.now()});
    } catch (e) {
      print('Error updating user data in Firestore: $e');
    }
  }

  void showLoginSuccessfulDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:   Color(0xFFdeb887),
          title: Center(
            child: Text(
              'Login Successful',
              style: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to the home page or any other page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
  // wrong email message popup
  void showEmptyFieldDialog(BuildContext context,String fieldName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Empty Password Field'),
          content: Text('Please enter your password $fieldName' ),
          actions: [
            ElevatedButton(
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

  void showInvalidCredentialsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invalid Credentials'),
          content: Text('Invalid email or password'),
          actions: [
            ElevatedButton(
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
  void wrongCredentialMessage(BuildContext context, String fieldName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:   Color(0xFFdeb887),
          title: Text('Invalid Credentials'),
          content: Text('Invalid $fieldName'),
          actions: [
            ElevatedButton(
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

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
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
              height: MediaQuery.of(context).size.height * 0.6,
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
                    "Login",
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
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.1), width: 0.5),
                      ),
                      child: TextField(
                        controller: emailController,
                        style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).size.height * 0.015),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixText: "",
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6.5),
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
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.1), width: 0.5),
                      ),
                      child: TextField(
                        controller: passwordController,
                        style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).size.height * 0.015),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixText: "",
                         // hintText: "Enter your password",
                          hintStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.015
                          ,
                            color: Colors.grey,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6.5),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: _obscureText ? Colors.grey : Colors.black,

                            ), onPressed: () {
                              setState(()
                              {
                                _obscureText =!_obscureText;
                              }
                              );
                          },
                          ),
                        ),
                        obscureText: _obscureText,
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
                          "Log in",
                          style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: MediaQuery.of(context).size.height * 0.018,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Satoshi',
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        onPressed: () {
                          signUserIn();
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 1.0),  // Adjust the padding as needed
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Show a dialog to input email
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController emailController = TextEditingController();
                                return AlertDialog(
                                  title: Text('Forgot Password?'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Enter your email to reset the password:'),
                                      TextField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          hintText: 'Email',
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFFdeb887)), // Change the color as needed
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        // Call the resetPassword method
                                        resetPassword(emailController.text);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFdeb887), // Background color
                                        foregroundColor: Colors.white, // Text color
                                      ),
                                      child: Text('Reset Password'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xff101828),
                              fontSize: MediaQuery.of(context).size.height * 0.017,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Satoshi',
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),

                        Spacer(),  // Creates space between the two buttons
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                          },
                          child: Text(
                            'Skip >>',
                            style: TextStyle(
                              color: Color(0xFFdeb887),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Satoshi',
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
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
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign up',
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
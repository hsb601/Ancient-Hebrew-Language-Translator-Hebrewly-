import 'package:ancient_language_translator/login.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:ancient_language_translator/prompt.dart';
import 'package:ancient_language_translator/about.dart';
import 'package:ancient_language_translator/profile.dart';
import 'package:ancient_language_translator/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ancient_language_translator/guest_prompt.dart';

TextEditingController guestIdController = TextEditingController();
String enteredGuestId = '';
Future<bool> showGuestIdDialog(BuildContext context, String guestUid) async {
  bool isGuest = false;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter Guest ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Please enter the guest ID'),
            ),
            TextField(
              controller: guestIdController,
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFdeb887)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              String enteredGuestId = guestIdController.text;
              if (enteredGuestId == guestUid) {
                isGuest = true;
              }
              Navigator.of(context).pop(isGuest);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFdeb887),
              foregroundColor: Colors.white,
            ),
            child: Text('Submit'),
          ),
        ],
      );
    },
  );

  return isGuest;
}

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  String? _profileImageUrl;
  void _showDialog(BuildContext context, String title, String content) {
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

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    setState(() {
      nameController.text = "User";
      emailController.text = "";
      phoneNumberController.text = "";
      dobController.text = "";
    });
    showLogoutSuccessfulDialog();
  }

   User? _user;

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
  }

  void initializeFlutterFire() async {
    await Firebase.initializeApp();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
        nameController.text = "User";
      });

      if (_user != null) {
        loadUserData();
      }
    });
  }

  void showLogoutSuccessfulDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFdeb887),
          title: Center(
            child: Text(
              'Successfully Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
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

  void loadUserData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          nameController.text = snapshot['name'] ?? '';

          // Check if profile image URL exists in the document
          if (snapshot.data()!.containsKey('profileImage')) {
            _profileImageUrl = snapshot['profileImage'];
          }
        });
      } else {
        nameController.text = "User";
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 275,
      backgroundColor: Colors.white,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 80, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 275,
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/a.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.black,
                          child: CircleAvatar(
                            radius: 39,
                            backgroundImage: _user != null && _profileImageUrl != null
                                ? CachedNetworkImageProvider(_profileImageUrl!) as ImageProvider<Object>
                                : AssetImage("assets/profile.jpg"),
                          ),
                        ),

                        alignment: Alignment.center,
                      )
                    ],
                  ),
                  Text(
                    nameController.text,
                    style: TextStyle(
                      color: Color(0xFFdeb887),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 25),
                  if (_user != null)
                  DrawerItems(
                    title: 'Profile',
                    icon: Icons.account_circle,
                    onTap: () async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                      }
    else{
      print('User not authenticated');
      _showDialog(context, "Permission Not Granted", "Please Authenticate Signup/Login first!");

    }
                    },
                  ),
                  DrawerItems(
                    title: 'Home',
                    icon: Icons.home,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    },
                  ),
                  DrawerItems(
                    title: 'About',
                    icon: Icons.info_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutScreen(),
                        ),
                      );
                    },
                  ),
                  DrawerItems(
                    title: 'Signup',
                    icon: Icons.login_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(),
                        ),
                      );
                    },
                  ),
                  if (_user != null)
    DrawerItems(
    title: 'Prompt',
      icon: Icons.messenger_outline,
      onTap: () {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // If the user is authenticated
          String uid = user.uid;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PromptScreen(uid: uid),
            ),
          );
        } else {
          // If the user is not authenticated
          // Check if enteredGuestId is not null or empty
          if (enteredGuestId.isNotEmpty) {
            String guestUid = 'ssuet_guest'; // Replace with your actual guest ID
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PromptGuestScreen(uid: guestUid),
              ),
            );
          } else {
            // Show the guest ID dialog and handle the logic within its callback
            showGuestIdDialog(context, 'ssuet_guest').then((isGuest) {
              if (isGuest) {
                enteredGuestId = 'ssuet_guest'; // Save the entered guest ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PromptGuestScreen(uid: enteredGuestId),
                  ),
                );
              } else {
                _showDialog(context, "Permission Not Granted", "Please enter a valid guest id");
              }
            });
          }
        }
      },
    ),


    Divider(
                    height: 35,
                    color: Colors.black,
                  ),
                ],
              ),
              if (_user != null)
                DrawerItems(
                  title: 'Logout',
                  icon: Icons.logout,
                  onTap: () {
                    signUserOut();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerItems extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DrawerItems({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            IconButton(
              onPressed: onTap,
              icon: Icon(
                icon,
                color: Colors.black,
                size: 20,
              ),
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

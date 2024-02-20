import 'package:ancient_language_translator/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  late User? _user;

  String? _profileImageUrl;

  PickedFile? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _selectedImage = PickedFile(pickedFile.path);
        }
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }




  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
  }

  // Initialize Firebase
  void initializeFlutterFire() async {
    await Firebase.initializeApp();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });

      // Load user data when user is logged in
      if (_user != null) {
        loadUserData();
      }
    });
  }

  Future<void> saveUserData(String uid, String name, String email, String phoneNumber, String dob) async {
    try {
      // Check if a new image is selected
      if (_selectedImage != null) {
        // Use a fixed image name based on the user's UID
        String imageName = 'profile_images/$uid/profile_picture.jpg';
        Reference storageReference = FirebaseStorage.instance.ref().child(imageName);
        UploadTask uploadTask = storageReference.putFile(File(_selectedImage!.path));

        // Show loading indicator while uploading
        showLoadingDialog();

        // Wait for the upload to complete
        await uploadTask.whenComplete(() {
          // Close loading indicator
          Navigator.of(context).pop();
        });

        // Get the download URL of the uploaded image
        String imageUrl = await storageReference.getDownloadURL();

        if (_user != null) {
          // Save user data including the image URL
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'name': name,
            'email': email,
            'phoneNumber': phoneNumber,
            'dob': dob,
            'profileImage': imageUrl,
          });
        } else {
          _showDialog("Not Authenticate", "Please Login!");
        }
      } else {
        // Save user data without the image URL
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'dob': dob,
        });
      }

      _showDialog("Saved", "Your data updated successfully!");
    } catch (e) {
      // Handle Firebase exceptions
      if (e is FirebaseException) {
        _showDialog("Error", "Error uploading image: ${e.message}");
      } else {
        _showDialog("Error", "Unexpected error: $e");
      }

      print('Error saving user data: $e');
    }
  }


  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Uploading profile image..."),
            ],
          ),
        );
      },
    );
  }

  void showLogoutSuccessfulDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:   Color(0xFFdeb887),
          title: Center(
            child: Text(
              'Successfully Logout',
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
  void signUserOut() {
    FirebaseAuth.instance.signOut();
    setState(() {
      nameController.text = "";
       emailController.text = "";
       phoneNumberController.text = "";
       dobController.text = "";

    });
    showLogoutSuccessfulDialog();
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
  // Load user data from Firestore
  void loadUserData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          nameController.text = snapshot['name'] ?? '';
          emailController.text = snapshot['email'] ?? '';
          phoneNumberController.text = snapshot['phoneNumber'] ?? '';
          dobController.text = snapshot['dob'] ?? '';

          // Check if profile image URL exists
          if (snapshot['profileImage'] != null) {
            // Set the profile image URL
            _profileImageUrl = snapshot['profileImage'];
          }
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color(0xFFdeb887),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 40, right: 20),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("",
                            style: TextStyle(
                                color: Color(0xff101828),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Satoshi')),


                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.only(top: 10),
                          child: _user != null ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xffdeb887),
                              shadowColor: Colors.grey[400],
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            onPressed: () {
                              saveUserData(
                                _user!.uid,
                                nameController.text,
                                emailController.text,
                                phoneNumberController.text,
                                dobController.text,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.cloud_upload,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  const Text(
                                    "Save",
                                    style: TextStyle(
                                        fontSize: 16, color: Color(0xffdeb887)),
                                  )
                                ],
                              ),
                            ),
                          ) : Container(), // This Container will be empty if the user is not logged in
                        ),

                        if (_user != null)
                        const SizedBox(
                          height: 10,
                        ),
                        if (_user != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xffdeb887),
                                shadowColor: Colors.grey[400],
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                              ),
                              onPressed: () {
                                 signUserOut() ;
                                 },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.logout,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    const Text(
                                      "Logout",
                                      style: TextStyle(
                                          fontSize: 16, color: Color(0xffdeb887)),
                                    )
                                  ],
                                ),
                              )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white10.withOpacity(0.1),
                                          spreadRadius: 0.1,
                                          blurRadius: 10,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: _profileImageUrl != null
                                          ? Image(
                                        image: CachedNetworkImageProvider(_profileImageUrl!),
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      )
                                          : _user != null
                                          ? (_selectedImage != null
                                          ? Image.file(
                                        File(_selectedImage!.path),
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      )
                                          : Image.asset(
                                        "assets/profile.jpg",
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      ))
                                          : Image.asset(
                                        "assets/profile.jpg",
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 30,
                                    right: 20,
                                    child: GestureDetector(
                                      onTap: () {
                                        _pickImage();
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        padding: EdgeInsets.all(2.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFdeb887),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(0),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 3,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name",
                                  style: TextStyle(
                                      color: Color(0xffffffff),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Satoshi')),
                              SizedBox(
                                height: 2,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 70,
                                child: Container(
                                  margin: EdgeInsets.all(4),
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(16, 24, 40, 0.05),
                                        blurRadius: 2,
                                        spreadRadius: 1,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(8.0),
                                    border:
                                    Border.all(color: Color(0xffD0D5DD), width: 1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: TextField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text("Email",
                                  style: TextStyle(
                                      color: Color(0xffffffff),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Satoshi')),
                              SizedBox(
                                height: 2,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 70,
                                child: Container(
                                  margin: EdgeInsets.all(4),
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(16, 24, 40, 0.05),
                                        blurRadius: 2,
                                        spreadRadius: 1,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(8.0),
                                    border:
                                    Border.all(color: Color(0xffD0D5DD), width: 1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: TextField(
                                      controller: emailController,
                                      readOnly: true, // Set this to true to make the TextField read-only
                                      enabled: false, // Optionally set this to false to disable user interaction
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text("Phone Number",
                                  style: TextStyle(
                                      color: Color(0xffffffff),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Satoshi')),
                              SizedBox(
                                height: 2,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 70,
                                child: Container(
                                  margin: EdgeInsets.all(4),
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(16, 24, 40, 0.05),
                                        blurRadius: 2,
                                        spreadRadius: 1,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(8.0),
                                    border:
                                    Border.all(color: Color(0xffD0D5DD), width: 1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: TextField(
                                      controller: phoneNumberController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text("Date of birth",
                                  style: TextStyle(
                                      color: Color(0xffffffff),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Satoshi')),
                              SizedBox(
                                height: 2,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 70,
                                child: Container(
                                  margin: EdgeInsets.all(4),
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(16, 24, 40, 0.05),
                                        blurRadius: 2,
                                        spreadRadius: 1,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(8.0),
                                    border:
                                    Border.all(color: Color(0xffD0D5DD), width: 1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: TextField(
                                      controller: dobController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

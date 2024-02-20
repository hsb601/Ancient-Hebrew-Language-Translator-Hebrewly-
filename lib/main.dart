import 'dart:io';
import 'package:ancient_language_translator/login.dart';
import 'package:ancient_language_translator/prompt.dart';
import 'package:ancient_language_translator/signup.dart';
import 'package:ancient_language_translator/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'drawer.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ancient_language_translator/guest_prompt.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        drawerTheme: DrawerThemeData(scrimColor: Colors.transparent),
      ),
      title: 'Hebrewly',
      home:
      // HomePage()
      // HomePage()

       SplashScreen(),
      // SignupScreen(),
      // LoginPage(),
      // PromptScreen()
      // SplashScreen(),
    );
  }
}


class HomeController extends GetxController {
  RxString scannedText = ''.obs;

  void setScannedText(String text) {
    scannedText.value = text;
  }
}

class HomePage extends StatefulWidget {
  final HomeController controller = Get.put(HomeController());
  // const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  bool textScanning = false;
  XFile? imageFile;
  String scannedText = "";

  Future<void> loadJsonFile() async {
    try {
      final jsonString = await rootBundle.loadString('Insert Json String here');
      print('JSON String: $jsonString'); // Print the entire JSON string for debugging

      final jsonData = json.decode(jsonString);
      final apiKey = jsonData['private_key_id']; // Update this line to retrieve the correct key

      print('API Key: $apiKey'); // Print the API key for debugging

      final url = 'Insert URL here $apiKey';
      print('API URL: $url');

      // Use url and apiKey as needed
      // ...

    } catch (e) {
      print('Error loading JSON file: $e');
    }
  }
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

  void getImage(ImageSource source) async {
    try {
      await loadJsonFile(); // Load JSON file before getting the image
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      setState(() {});
      scannedText = "Error occurred while scanning";
    }
  }

  Future<void> _showTextDialog(String text) async {
    await Get.defaultDialog(
      title: 'Extracted Text',
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(text),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // If the user is authenticated
                  String uid = user.uid;
                  Get.find<HomeController>().setScannedText(text);
                  Get.to(() => PromptScreen(uid: uid));
                } else if (enteredGuestId.isNotEmpty) {
                  String guestUid = 'ssuet_guest'; // Replace with your actual guest ID
                  Get.find<HomeController>().setScannedText(text);
                  Get.to(() => PromptGuestScreen(uid: guestUid));
                } else {
                  // If the user is not authenticated
                  // Show the guest ID dialog and handle the logic within its callback
                  showGuestIdDialog(context, 'ssuet_guest').then((isGuest) {
                    if (isGuest) {
                      enteredGuestId = 'ssuet_guest'; // Save the entered guest ID
                      Get.find<HomeController>().setScannedText(text);
                      Get.to(() => PromptGuestScreen(uid: enteredGuestId));
                    } else {
                      _showDialog(context, "Permission Not Granted", "Please enter a valid guest id");
                    }
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffdeb887),
                foregroundColor: Colors.white,// Set the background color
              ),
              child: Text('Send To PromptScreen'),
            ),
          ],
        ),
      ),
    );
  }


  // Future<void> _showTextDialog(String text) async {
  //   return Get.defaultDialog(
  //     title: 'Extracted Text',
  //     content: SingleChildScrollView(
  //       child: ListBody(
  //         children: [
  //           Text(text),
  //           const SizedBox(height: 16),
  //           ElevatedButton(
  //             onPressed: () {
  //               Get.to(() => PromptScreen());
  //             },
  //             child: Text('Go to PromptScreen'),
  //           ),
  //
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Future<bool> showGuestIdDialog(BuildContext context, String guestUid) async {
    TextEditingController guestIdController = TextEditingController();
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
                    borderSide: BorderSide(color: Color(0xFFdeb887)), // Change the color as needed
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Check if the entered guest ID is correct
                String enteredGuestId = guestIdController.text;
                if (enteredGuestId == guestUid) {
                  isGuest = true;
                }
                Navigator.of(context).pop(isGuest);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFdeb887), // Background color
                foregroundColor: Colors.white, // Text color
              ),
              child: Text('Submit'),
            ),
          ],
        );
      },
    );

    return isGuest;
  }

  void _popToHomePage() {
    // Check if the widget is still mounted before accessing context
    if (mounted) {
      Navigator.pop(context);
    } else {
      // The widget is no longer mounted, handle accordingly (e.g., log a message).
      print('Trying to pop, but widget is unmounted');
    }
  }

  Future<void> getRecognisedText(XFile image) async {

    final apiKey = 'Enter API key here';
    // final apiKey = 'd8ff1c0fdbdaeb627e4bd7555fa882c4b9c56e12';
    final apiUrl = 'Enter API Url here=$apiKey';

    try {
      final imageBytes = await File(image.path).readAsBytes();

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Encode(imageBytes)},
              'features': [{'type': 'TEXT_DETECTION'}],
              'imageContext': {'languageHints': ['he']}
            }
          ]
        }),
      );

      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded.containsKey('responses') &&
            decoded['responses'].isNotEmpty &&
            decoded['responses'][0].containsKey('textAnnotations') &&
            decoded['responses'][0]['textAnnotations'].isNotEmpty &&
            decoded['responses'][0]['textAnnotations'][0].containsKey('description')) {
          final extractedText =
          decoded['responses'][0]['textAnnotations'][0]['description'];

          setState(() {
            scannedText = extractedText;
          });
          _showTextDialog(extractedText);

        } else {
          setState(() {
            scannedText = "Error: Invalid API response format.";
          });
        }
      } else {
        setState(() {
          scannedText = "Error: ${response.statusCode}";
        });

      }
    } catch (e) {
      setState(() {
        scannedText = "Error: $e";
      });
    } finally {
      setState(() {
        textScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xffdeb887),
      drawer: DrawerPage(),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Ancient Language \n       Translator",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              if (textScanning) const CircularProgressIndicator(),
              if (!textScanning && imageFile == null)
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage("assets/robotlogo.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (imageFile != null) Image.file(File(imageFile!.path)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xffdeb887),
                          shadowColor: Colors.grey[400],
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          getImage(ImageSource.gallery);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.image,
                                size: 20,
                              ),
                              const Text(
                                "Gallery",
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xffdeb887)),
                              )
                            ],
                          ),
                        )),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xffdeb887),
                          shadowColor: Colors.grey[400],
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          getImage(ImageSource.camera);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.camera_alt_outlined,
                                size: 20,
                              ),
                              const Text(
                                "Camera",
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xffdeb887)),
                              )
                            ],
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
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

                          _showDialog(context, "Coming Soon", "In Version: 1.1");

                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.document_scanner_outlined,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          const Text(
                            "Documents",
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.only(top: 10),

              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xffdeb887),
                  shadowColor: Colors.grey[400],
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                onPressed: () async {
                  HapticFeedback.heavyImpact();
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    String uid = user.uid;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PromptScreen(uid: uid),
                      ),
                    );
                  } else if (enteredGuestId.isNotEmpty) {
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
                        _showDialog(context, "Permission Not Granted", "Please enter valid guest id");
                      }
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.messenger_outline,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      const Text(
                        "Prompt",
                        style: TextStyle(fontSize: 16, color: Color(0xffdeb887)),
                      ),
                    ],
                  ),
                ),
              ),



              // Container(
              //   child: Text(
              //     scannedText,
              //     style: const TextStyle(fontSize: 20),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}









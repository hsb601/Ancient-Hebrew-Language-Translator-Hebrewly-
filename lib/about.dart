import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  // Open Gmail app when the Gmail address is tapped

  _launchGmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'hebrewlybottranslator@gmail.com',
      queryParameters: {'subject': 'Welcome from Hebrewly!'},
    );

    final String emailLaunchUriString = emailLaunchUri.toString();

    if (await canLaunchUrlString(emailLaunchUriString)) {
      await launchUrlString(emailLaunchUriString);
    } else {
      throw 'Could not launch $emailLaunchUriString';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "About",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color(0xFFdeb887),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/chatbot.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.width * 0.75,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                        Border.all(color: Color(0xFF7C4700), width: 2),
                      ),
                      child: Text(
                        'Ancient language Translator (Hebrewly)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFdeb887),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      width: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                        Border.all(color: Color(0xFF7C4700), width: 2),
                      ),
                      child: Text(
                        'An AI-based Ancient Hebrew Language Translator involves constructing a comprehensive dataset, implementing Transformer model architecture, and integrating OCR for image processing, with a focus on preserving ancient languages in the digital age.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFFdeb887),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      padding: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                        Border.all(color: Color(0xFF7C4700), width: 2),
                      ),
                      child: GestureDetector(
                        onTap: _launchGmail,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mail_outline_outlined,
                              color: Color(0xFFdeb887),
                            ),
                            Text(
                              'Gmail:',
                              style: TextStyle(
                                  fontSize: 15, color: Color(0xFFdeb887)),
                            ),
                            Text(
                              ' hebrewlybottranslator@gmail.com',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFdeb887),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                padding: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFF7C4700), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Instructions',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFdeb887),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '1. If you have not signed up with a valid email like Gmail or Yahoo, you will not be able to use the "Forgot Password" functionality.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFFdeb887),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '2. If you want to delete your account, send us an email to delete account with the correct email you registered with our app. After delete Your account, you will not be able to access the app from that account. If you create a new account with same credentials you will not be able to access your previous account data chats etc.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFFdeb887),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

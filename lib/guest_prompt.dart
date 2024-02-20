import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ancient_language_translator/drawer.dart';
import 'package:ancient_language_translator/main.dart';

String _getTime(DateTime time) {
  var formattedTime = DateFormat.yMMMMd().add_jm().format(time);
  return formattedTime;
}

void openGuestPromptScreen(BuildContext context) {

    showGuestIdDialog(context, 'ssuet_guest').then((isGuest) {
      if (isGuest) {
        String guestUid = 'ssuet_guest'; // Replace with your actual guest ID
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PromptGuestScreen(uid: guestUid)
          ),
        );
      } else {
        // Handle the case when the user is not authenticated and not a guest
        print('User not authenticated');
        _showDialog(
          context,
          "Permission Not Granted",
          "Please Authenticate Signup/Login first!",
        );
      }
    });

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


class PromptGuestScreen extends StatefulWidget {
  final String uid;

  PromptGuestScreen({required this.uid});
  @override
  _PromptGuestScreenState createState() => _PromptGuestScreenState();
}

class _PromptGuestScreenState extends State<PromptGuestScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      sender: 'Hebrewly_Bot',
      message: 'History is a set of lies agreed upon — Napoleon Bonaparte.',
      time: 'Feb 10, 2023 6:03 PM',
      translationLanguage: 'en',
    ),
    ChatMessage(
      sender: 'User',
      message: 'היסטוריה היא אוסף של שקרים שהוסכם עליהם - נפוליאון בונפרטה.',
      time: 'Feb 10, 2023 6:02 PM',
      translationLanguage: 'he',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller.text = Get.find<HomeController>().scannedText.value;
  }

  Future<void> _sendMessage(String message) async {
    if (message.isNotEmpty) {
      if (_containsEnglishCharacters(message)) {
        _showEnglishErrorSnackBar();
      } else {
        try {
          final response = await http.post(
            Uri.parse(
                'Enter Flask API Url here with method /Prediction'),
            body: {'input_text': message},
          );

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = response.body.isNotEmpty
                ? json.decode(response.body)
                : {'error': 'Empty response'};

            setState(() {
              _messages.insert(
                0, // Add messages at the beginning of the list
                ChatMessage(
                  sender: 'User',
                  message: message,
                  time: _getTime(DateTime.now()),
                  translationLanguage: 'he',
                ),
              );
              _messages.insert(
                0, // Add messages at the beginning of the list
                ChatMessage(
                  sender: 'Hebrewly_Bot',
                  message: data['generated_text'],
                  time: _getTime(DateTime.now()),
                  translationLanguage: 'en',
                ),
              );
            });


            print('Generated Text: ${data['generated_text']}');



          } else {
            print('Error: ${response.statusCode}');
            _showErrorDialog('Error: ${response.statusCode}');
          }
        } catch (e) {
          print('Exception: $e');
          _showErrorDialog('Exception: $e');
        }
      }
    } else {
      _showEmptyMessageDialog();
    }
  }






  bool _containsEnglishCharacters(String text) {
    final regex = RegExp(r'[a-zA-Z]');
    return regex.hasMatch(text);
  }

  void _showEnglishErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.all(16),
          height: 80,
          width: 2,
          decoration: BoxDecoration(
            color: Color(0xFFdeb887),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            children: [
              Text(
                "Error!",
                style: TextStyle(fontSize: 18, color: Colors.red.shade900),
              ),
              Text(
                "Please enter only Hebrew text.",
                style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showEmptyMessageDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.all(16),
          height: 80,
          width: 2,
          decoration: BoxDecoration(
            color: Color(0xFFdeb887),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            children: [
              Text(
                "Error!",
                style: TextStyle(fontSize: 18, color: Colors.red.shade900),
              ),
              Text(
                "Empty text field.",
                style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: Duration(seconds: 2),
      ),
    );
  }


  bool isOnline = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leadingWidth: 70,
        backgroundColor: Color(0xFFdeb887),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back_ios_sharp,
                size: 24,
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: Image.asset("assets/chatbot.jpeg").image,

              ),

            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Hebrewly Bot"),
            Text(isOnline ? "Online" : "Offline",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Hi!'),
                    content: Text('I am Hebrewly bot'),
                  );
                },
              );
            },
            child: Container(
              width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent // Set a background color
              ),
              child: Image.asset(
                'assets/icon.png',
                width: 150, // Adjust the width as needed
                height: 150, // Adjust the height as needed
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: ChatScreen(
          controller: _controller,
          onSendMessage: _sendMessage,
          messages: _messages),
    );
  }
}


class ChatScreen extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final List<ChatMessage> messages;
  Map<int, String> selectedLanguages = {};

  ChatScreen({
    required this.controller,
    required this.onSendMessage,
    required this.messages,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(widget.messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isCurrentUser = message.sender == 'User';

    return Container(
      margin: EdgeInsets.only(
        bottom: 6.0,
        left: isCurrentUser ? 60.0 : 0.0,
        right: isCurrentUser ? 0.0 : 60.0,
      ),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Color(0xFFdeb887),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isCurrentUser ? 8.0 : 0.0),
          topRight: Radius.circular(isCurrentUser ? 0.0 : 8.0),
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message.message,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          SizedBox(height: 4.0),
          Text(
            message.time,
            style: TextStyle(color: Color(0xFFdfe4ea), fontSize: 14.0),
          ),
          if (!isCurrentUser) _buildTranslationDropdown(message),
        ],
      ),
    );
  }

  Widget _buildTranslationDropdown(ChatMessage message) {
    print('Translation Language: ${message.translationLanguage}');
    print('Available Languages: [en, ur, fr]');

    final availableLanguages = ['en', 'ur', 'fr'];

    return Container(
      margin: EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Text(
            "Translate to: ",
            style: TextStyle(color: Color(0xFFdfe4ea), fontSize: 14.0),
          ),
          DropdownButton<String>(
            value: availableLanguages.contains(message.translationLanguage)
                ? message.translationLanguage
                : availableLanguages.first,
            onChanged: (newValue) {
              if (newValue != null) {
                _translateMessage(message, newValue);
              }
            },
            items: availableLanguages
                .map<DropdownMenuItem<String>>(
                  (value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }


  Future<void> _translateMessage(ChatMessage message, String targetLanguage) async {
    final apiKey = 'Enter API key here';

    final response = await http.post(
      Uri.parse('Enter API Url here'),
      body: {
        'key': apiKey,
        'q': message.message,
        'source': message.translationLanguage, // Use the source language from the message
        'target': targetLanguage,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final translatedText = data['data']['translations'][0]['translatedText'];

      setState(() {
        message.translationLanguage = targetLanguage;
        message.setMessage = translatedText;
      });
    } else {
      print('Error: ${response.statusCode}');
      // Handle error
    }
  }






  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Color(0xFFdeb887).withOpacity(0.4),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14.0),
          topRight: Radius.circular(14.0),
        ),
      ),
      child: Column(
        children: [

          SizedBox(height: 10,),
          Row(
            children: [

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the corner radius as needed
                    color: Colors.white, // Set the background color of the text field
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffdeb887).withOpacity(0.9),
                        blurRadius: 5, // Adjust the shadow blur radius
                        offset: Offset(1, 3), // Adjust the shadow offset
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 100.0,
                    ),
                    child: TextField(
                      controller: widget.controller,
                      onChanged: (message) {},
                      onSubmitted: widget.onSendMessage,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Prompt:',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  //HapticFeedback.heavyImpact();
                  widget.onSendMessage(widget.controller.text);
                },
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xffdeb887),
                      ),
                    ),
                    Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

    );
  }
}

class ChatMessage {
  final String sender;
  String message; // Change this line
  final String time;
  String translationLanguage; // Add this line

  ChatMessage({
    required this.sender,
    required this.message,
    required this.time,
    required this.translationLanguage, // Add this line
  });

  // Add this setter for 'message'
  set setMessage(String newMessage) {
    message = newMessage;
  }
}
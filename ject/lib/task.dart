import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For converting data to/from JSON
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ViewTasksPage extends StatefulWidget {
  @override
  _ViewTasksPageState createState() => _ViewTasksPageState();
}

class _ViewTasksPageState extends State<ViewTasksPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = []; // List to store messages
  late String serverIp; // Variable to store the server IP
  late stt.SpeechToText _speechToText;
  bool _isListening = false; // To track if the mic is listening
  String _speechText = ''; // Store the converted speech text
  final ScrollController _scrollController = ScrollController(); // Scroll controller for auto-scrolling

  @override
  void initState() {
    super.initState();
    _loadServerIp(); // Load server IP on page initialization
    _speechToText = stt.SpeechToText();
  }

  // Function to load server IP from SharedPreferences
  Future<void> _loadServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      serverIp = prefs.getString('ip_address') ?? 'http://192.168.0.179:5000'; // Default IP if not set
    });
  }

  // Function to send a message and close the keyboard
  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) {
      return;
    }

    String userMessage = _messageController.text;

    setState(() {
      _messages.add({'sender': 'user', 'message': userMessage});
      _messageController.clear();
    });

    // Close the keyboard
    FocusScope.of(context).unfocus();

    // Scroll to the bottom
    _scrollToBottom();

    // Get the bot's response
    await _getBotResponse(userMessage);
  }

  // Function to get the bot's response from the server
  Future<void> _getBotResponse(String userMessage) async {
    String response = 'Sorry, I did not understand that.';

    try {
      final uri = Uri.parse('$serverIp/api/process-input');
      final responseFromServer = await http.post(
        uri,
        body: json.encode({'text': userMessage}),
        headers: {'Content-Type': 'application/json'},
      );

      if (responseFromServer.statusCode == 200) {
        final data = json.decode(responseFromServer.body);
        response = data['response'] ?? 'Sorry, no response from the server.';
      } else {
        response = 'Failed to communicate with the server.';
      }
    } catch (e) {
      response = 'Error: $e';
    }

    setState(() {
      _messages.add({'sender': 'bot', 'message': response});
    });

    // Scroll to the bottom after receiving a message
    _scrollToBottom();
  }

  // Function to scroll to the bottom
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Function to start and stop speech-to-text
  void _toggleSpeech() async {
    if (_isListening) {
      _speechToText.stop();
      setState(() {
        _isListening = false;
        _messageController.text = _speechText;
      });
    } else {
      bool available = await _speechToText.initialize();
      if (available) {
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _speechText = result.recognizedWords;
              _messageController.text = _speechText;
            });
          },
        );
        setState(() {
          _isListening = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Chatbot'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Attach scroll controller
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message['sender'] == 'user'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message['sender'] == 'user'
                            ? Colors.blue[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['message']!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    color: _isListening ? Colors.red : Colors.blue,
                  ),
                  onPressed: _toggleSpeech,
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

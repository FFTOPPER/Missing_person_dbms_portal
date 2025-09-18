import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  double? latitude;
  double? longitude;
  bool _locationPermissionGranted = false;

  // Hardcoded server IP address
  final String serverIp = 'http://192.168.1.8:5000';

  @override
  void initState() {
    super.initState();
    _requestLocationPermission(); // Request location permission on app start
  }

  Future<void> _requestLocationPermission() async {
    try {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showErrorDialog('Location services must be enabled to use this feature.');
          return;
        }
      }

      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted) {
          _showErrorDialog('Location permission is required for this app.');
          return;
        }
      }

      if (permission == PermissionStatus.deniedForever) {
        _showPermissionDialog();
        return;
      }

      LocationData locationData = await location.getLocation();
      setState(() {
        latitude = locationData.latitude;
        longitude = locationData.longitude;
        _locationPermissionGranted = true;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text('This app needs location access. Please enable it from app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    if (!_locationPermissionGranted || latitude == null || longitude == null) {
      _showErrorDialog('Location access is required to send messages.');
      return;
    }

    String userMessage = _messageController.text;
    String timestamp = _getCurrentTime();

    setState(() {
      _messages.add({
        'sender': 'user',
        'message': userMessage,
        'timestamp': timestamp,
      });
      _messageController.clear();
    });

    FocusScope.of(context).unfocus();
    _scrollToBottom();

    await _sendMessageWithLocation(userMessage);
  }

  Future<void> _sendMessageWithLocation(String userMessage) async {
    String botResponse = 'Sorry, I did not understand that.';
    String timestamp = _getCurrentTime();

    try {
      final uri = Uri.parse('$serverIp/api');
      final response = await http.post(
        uri,
        body: json.encode({
          'text': userMessage,
          'latitude': latitude,
          'longitude': longitude
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        botResponse = data['response'].toString();
      } else {
        botResponse = '⚠ Failed to communicate with the server.';
      }
    } catch (e) {
      botResponse = '❌ Error: $e';
    }

    setState(() {
      _messages.add({
        'sender': 'bot',
        'message': botResponse,
        'timestamp': timestamp,
      });
    });

    _scrollToBottom();
  }

  String _getCurrentTime() {
    return DateFormat('hh:mm a').format(DateTime.now());
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message['sender'] == 'user';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment:
                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.smart_toy, color: Colors.white),
                        ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment:
                        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[100] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Text(
                              message['message']!,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            message['timestamp']!,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
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

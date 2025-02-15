import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SpeechToTextPage extends StatefulWidget {
  @override
  _SpeechToTextPageState createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = ""; // Store recognized speech
  String _statusText = "Press the mic to start speaking"; // Status message
  String serverIp = 'http://192.168.0.179:5000'; // Default IP

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadServerIp(); // Load the server IP from shared preferences
  }

  // Load server IP from shared preferences
  Future<void> _loadServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      serverIp = prefs.getString('ip_address') ?? 'http://192.168.0.179:5000'; // Default IP if not set
    });
  }

  // Function to start listening to speech
  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _statusText = "Listening..."; // Update status to show "Listening..."
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
        listenMode: stt.ListenMode.dictation, // Keeps listening even with short pauses
      );
    } else {
      setState(() {
        _statusText = "Speech recognition not available";
      });
    }
  }

  // Function to stop listening
  void _stopListening() {
    setState(() {
      _isListening = false;
      _statusText = "Press the mic to start speaking"; // Reset status text
    });
    _speech.stop();
  }

  // Function to send recognized text to the server
  Future<void> _sendRecognizedText() async {
    if (_recognizedText.isEmpty) {
      setState(() {
        _statusText = "No text to upload!";
      });
      return;
    }

    try {
      final uri = Uri.parse('$serverIp/api/store-task'); // Updated endpoint
      final response = await http.post(
        uri,
        body: json.encode({'message': _recognizedText}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _statusText = "Data uploaded successfully!";
        });
        print("Response from server: ${response.body}");
      } else {
        setState(() {
          _statusText = "Failed to upload data: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _statusText = "Error uploading data";
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Speech to Text"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center contents vertically
          children: [
            Center(
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 50,
                  color: Colors.blue,
                ),
                onPressed: () {
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _startListening();
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            // Displaying the "Listening..." status
            Text(
              _statusText,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 20),
            // Displaying the transcribed text in a separate box
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _recognizedText.isEmpty ? "No text recognized" : _recognizedText,
                style: TextStyle(fontSize: 20, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            // Upload button
            if (_recognizedText.isNotEmpty) // Show the button only if text is recognized
              ElevatedButton(
                onPressed: _sendRecognizedText,
                child: Text("Upload"),
              ),
          ],
        ),
      ),
    );
  }
}

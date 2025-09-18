import 'package:flutter/material.dart';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  // Keywords and responses
  final Map<List<String>, String> responses = {
    ["hi", "hello", "hey", "whats up", "good morning", "good evening"]:
    "Hello! How can I assist you today?",
    ["fever", "temperature", "high fever"]:
    "For fever, stay hydrated, rest well, and take paracetamol if necessary. Consult a doctor if it persists.",
    ["cold", "cough", "sneezing", "flu"]:
    "Try drinking warm fluids, take rest, and consider taking vitamin C.",
    ["headache", "migraine", "head pain"]:
    "Stay hydrated, avoid bright lights, and take a mild pain reliever if needed.",
    ["stomach pain", "stomachache", "gas", "indigestion"]:
    "Drink warm water, avoid heavy foods, and take an antacid if needed.",
    ["thank you", "thanks"]:
    "You're welcome! Stay healthy!",
    ["bye", "goodbye", "see you"]:
    "Goodbye! Take care.",
  };

  // Function to find the best response
  String getResponse(String userMessage) {
    userMessage = userMessage.toLowerCase();

    for (var keywords in responses.keys) {
      if (keywords.any((keyword) => userMessage.contains(keyword))) {
        return responses[keywords]!;
      }
    }

    return "I'm not sure about that. Please consult a doctor for medical advice.";
  }

  void _sendMessage() {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({"user": userMessage});
      _controller.clear();

      String botResponse = getResponse(userMessage);
      _messages.add({"bot": botResponse});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medical Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.containsKey("user")
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message.containsKey("user") ? Colors.blue[200] : Colors.green[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message.values.first,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask a medical question...",
                      border: OutlineInputBorder(),
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

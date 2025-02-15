import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskDetailsPage extends StatefulWidget {
  final DateTime date;

  TaskDetailsPage({required this.date});

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final TextEditingController _taskDescriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _importantPersonController = TextEditingController();
  final TextEditingController _additionalQuestionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  // Function to load saved task details from SharedPreferences
  Future<void> _loadTaskData() async {
    final prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.date);

    // Load saved data from SharedPreferences
    _taskDescriptionController.text = prefs.getString('$formattedDate-taskDescription') ?? '';
    _timeController.text = prefs.getString('$formattedDate-time') ?? '';
    _importantPersonController.text = prefs.getString('$formattedDate-importantPerson') ?? '';
    _additionalQuestionController.text = prefs.getString('$formattedDate-additionalQuestion') ?? '';
  }

  // Function to save task locally
  Future<void> _saveTask() async {
    final prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('yyyy-MM-dd').format(widget.date);

    await prefs.setString('$formattedDate-taskDescription', _taskDescriptionController.text);
    await prefs.setString('$formattedDate-time', _timeController.text);
    await prefs.setString('$formattedDate-importantPerson', _importantPersonController.text);
    await prefs.setString('$formattedDate-additionalQuestion', _additionalQuestionController.text);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task saved locally')));
  }

  // Function to upload task to the server
  Future<void> _uploadTask() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch the IP address from SharedPreferences, with a fallback to a default IP
    String baseUrl = prefs.getString('ip_address') ?? 'http://default.ip';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/store-task'),  // Endpoint to store task data
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'date': DateFormat('yyyy-MM-dd').format(widget.date),
          'task_description': _taskDescriptionController.text,
          'time_to_complete': _timeController.text,
          'important_person': _importantPersonController.text,
          'additional_question': _additionalQuestionController.text,
        }),
      );

      // Handle the server response
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task uploaded successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload task')));
      }
    } catch (e) {
      // Handle any errors that occur during the request
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading task: $e')));
    }
  }

  // Helper function to build the input field container
  Widget _buildInputField(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),  // Thick black border
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,  // Remove default border
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Task Details for ${DateFormat('yyyy-MM-dd').format(widget.date)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildInputField(_taskDescriptionController, 'Task Description'),
              SizedBox(height: 10), // Add some space between fields
              _buildInputField(_timeController, 'Time to Complete'),
              SizedBox(height: 10),
              _buildInputField(_importantPersonController, 'Important Person'),
              SizedBox(height: 10),
              _buildInputField(_additionalQuestionController, 'Status'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _saveTask,
                    child: Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: _uploadTask,
                    child: Text('Upload'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

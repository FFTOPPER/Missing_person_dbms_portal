import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'upload.dart'; // Import UploadPage

class WhoIsThisPage extends StatefulWidget {
  @override
  _WhoIsThisPageState createState() => _WhoIsThisPageState();
}

class _WhoIsThisPageState extends State<WhoIsThisPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isLoading = false;

  // API response variables
  String _name = '';
  String _relation = '';
  String _description = '';
  String _createdAt = ''; // Stores when the person was previously visited
  Uint8List? _decodedImage; // Stores image from server response

  // Function to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  // Function to pick image from camera
  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  // Function to upload image
  Future<void> _uploadImage() async {
    if (_image == null) {
      _showErrorDialog('Please select an image.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String baseUrl = prefs.getString('ip_address') ?? 'http://default.ip';

    File imageFile = File(_image!.path);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    Map<String, dynamic> requestBody = {'image': base64Image};

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/match-image'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _name = responseData['name'] ?? 'Unknown';
          _relation = responseData['relation'] ?? 'Not specified';
          _description = responseData['description'] ?? 'No description available';

          // Decode and store image from response if available
          _decodedImage = responseData['image_data'] != null
              ? base64Decode(responseData['image_data'])
              : null;

          // Store the created_at field
          _createdAt = responseData['created_at'] ?? 'Not available';
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // If no match is found, navigate to UploadPage with the image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadPage(
              img: _image != null ? File(_image!.path) : null, // Convert XFile to File
            ),
          ),
        );
        setState(() => _isLoading = false);
      } else {
        _showErrorDialog('Failed to upload. Server error: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showErrorDialog('Error during upload: $e');
      setState(() => _isLoading = false);
    }
  }

  // Function to display error messages
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Who Is This?')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Display selected image
              _image != null
                  ? Image.file(File(_image!.path), height: 200, width: 200, fit: BoxFit.cover)
                  : Text('No image selected.', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),

              // Image picking buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                    onPressed: _pickImageFromCamera,
                  ),
                  SizedBox(width: 30),
                  IconButton(
                    icon: Icon(Icons.photo_library, size: 40, color: Colors.green),
                    onPressed: _pickImageFromGallery,
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Upload button
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),

              if (_isLoading) Center(child: CircularProgressIndicator()),

              // Display response details
              if (_name.isNotEmpty || _relation.isNotEmpty || _description.isNotEmpty) ...[
                _buildInfoBox('Name', _name),
                _buildInfoBox('Relation', _relation),
                _buildInfoBox('Description', _description),
              ],

              // Display image received from server
              if (_decodedImage != null) ...[
                SizedBox(height: 20),
                Text('Identified Image:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 10),
                Image.memory(_decodedImage!, height: 200, width: 200, fit: BoxFit.cover),
              ],

              // Display previously visited timestamp
              if (_createdAt.isNotEmpty) ...[
                SizedBox(height: 20),
                _buildInfoBox('Previously visited this person in:', _createdAt),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Function to build response info boxes
  Widget _buildInfoBox(String title, String value) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 16),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

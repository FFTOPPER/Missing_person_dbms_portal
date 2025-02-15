import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class UploadPage extends StatefulWidget {
  final File? img; // Accepts an image file

  UploadPage({this.img}); // Constructor with optional image parameter

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    if (widget.img != null) {
      _image = XFile(widget.img!.path); // Set image from constructor
    }
  }

  // Function to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File compressedImage = await _compressImage(File(image.path));
      setState(() {
        _image = XFile(compressedImage.path);
      });
    }
  }

  // Function to open camera and capture image
  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      File compressedImage = await _compressImage(File(image.path));
      setState(() {
        _image = XFile(compressedImage.path);
      });
    }
  }

  // Function to compress image
  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 50, // Adjust quality (1-100, lower means more compression)
      format: CompressFormat.jpeg,
    );

    return File(result!.path);
  }

  // Function to upload image and details to server
  Future<void> _uploadData() async {
    if (_image == null) {
      _showErrorDialog('Please select an image.');
      return;
    }

    String name = _nameController.text.trim();
    String relation = _relationController.text.trim();
    String description = _descriptionController.text.trim();

    if (name.isEmpty || relation.isEmpty || description.isEmpty) {
      _showErrorDialog('Please fill in all the details.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String baseUrl = prefs.getString('ip_address') ?? 'http://default.ip';

    File imageFile = File(_image!.path);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    Map<String, dynamic> requestBody = {
      'image': base64Image,
      'name': name,
      'relation': relation,
      'description': description,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/store-image'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog('Upload successful!');
      } else {
        _showErrorDialog('Failed to upload data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error during upload: $e');
    }
  }

  // Function to show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  // Function to show a success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to start listening and update text field with speech
  void _startListening(TextEditingController controller) async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speechToText.listen(onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
          });
        });
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speechToText.stop();
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image != null
                  ? Image.file(File(_image!.path), height: 200, width: 200)
                  : Text('No image selected.', style: TextStyle(fontSize: 18)),

              SizedBox(height: 20),

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

              if (_image != null) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.mic, color: Colors.blue),
                      onPressed: () => _startListening(_nameController),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _relationController,
                  decoration: InputDecoration(
                    labelText: 'Relation',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.mic, color: Colors.blue),
                      onPressed: () => _startListening(_relationController),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.mic, color: Colors.blue),
                      onPressed: () => _startListening(_descriptionController),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadData,
                  child: Text('Upload'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

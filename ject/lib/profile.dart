import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'emergency.dart'; // For passing emergency contact details
import 'premium.dart'; // For passing username

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImagePath;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _emergencyNameController = TextEditingController();
  TextEditingController _emergencyNumberController = TextEditingController();
  String? _email;
  String _currentPlan = "Free Basic Plan";
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image');
      _usernameController.text = prefs.getString('username') ?? '';

      _phoneController.text = prefs.getString('phone_number') ?? '';
      _addressController.text = prefs.getString('address') ?? '';
      _emergencyNameController.text = prefs.getString('emergency_name') ?? '';
      _emergencyNumberController.text = prefs.getString('emergency_number') ?? '';
      _currentPlan = prefs.getString('current_plan') ?? "Free Basic Plan";
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedFile.path);
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('phone_number', _phoneController.text);
    await prefs.setString('address', _addressController.text);
    await prefs.setString('emergency_name', _emergencyNameController.text);
    await prefs.setString('emergency_number', _emergencyNumberController.text);
    await prefs.setString('current_plan', _currentPlan);
  }

  Future<void> _logout() async {
    bool confirmLogout = await _showLogoutConfirmation();
    if (confirmLogout) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored user data

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    }
  }

  Future<bool> _showLogoutConfirmation() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout Confirmation"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Logout"),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.purple[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera, color: Colors.white),
            title: Text("Open Camera", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: Colors.white),
            title: Text("Choose from Gallery", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  void _openFullScreenImage() {
    if (_profileImagePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImage(imagePath: _profileImagePath!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      appBar: AppBar(
        title: Text("Profile", style: GoogleFonts.pacifico(fontSize: 26)),
        backgroundColor: Colors.purple[700],
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            GestureDetector(
              onTap: _openFullScreenImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.amberAccent,
                backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                child: _profileImagePath == null ? Icon(Icons.add_a_photo, size: 40, color: Colors.white) : null,
              ),
            ),
            SizedBox(height: 10),
            _userInfoCard(),
            _textField("Phone Number", _phoneController, TextInputType.phone),
            _textField("Address", _addressController, TextInputType.text),
            _textField("Emergency Contact Name", _emergencyNameController, TextInputType.text),
            _textField("Emergency Contact Number", _emergencyNumberController, TextInputType.phone),
            _planDropdown(),
            SizedBox(height: 20),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  Widget _userInfoCard() {
    return Card(
      color: Colors.purple[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.email, color: Colors.white),
        title: Text(_email ?? "No email saved", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, TextInputType keyboardType) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amberAccent),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amberAccent),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _planDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: DropdownButtonFormField<String>(
        value: _currentPlan,
        decoration: InputDecoration(
          labelText: "Current Plan",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        items: ["Free Basic Plan", "Premium Plan", "Enterprise Plan"].map((plan) {
          return DropdownMenuItem(value: plan, child: Text(plan));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _currentPlan = value!;
          });
        },
      ),
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      onPressed: _saveProfileData,
      child: Text("Save", style: TextStyle(fontSize: 18)),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;
  FullScreenImage({required this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(child: Image.file(File(imagePath))),
      ),
    );
  }
}

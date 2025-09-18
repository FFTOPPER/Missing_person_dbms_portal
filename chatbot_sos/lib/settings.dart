import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  String ipAddress = 'http://192.168.1.10:5000/api/process-input';
  String userName = "";

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ipAddress = prefs.getString('ip_address') ?? '192.168.0.1';
      userName = prefs.getString('user_name') ?? "User";
    });
  }

  Future<void> _saveIPAddress(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip_address', ip);
    setState(() {
      ipAddress = ip;
    });
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    setState(() {
      userName = name;
    });
  }

  void _showIPDialog() {
    _ipController.text = ipAddress;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter IP Address"),
        content: TextField(
          controller: _ipController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter new IP",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _saveIPAddress(_ipController.text);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showUserNameDialog() {
    final TextEditingController _nameController = TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter Your Name"),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter your name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _saveUserName(_nameController.text);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text("User Name: $userName"),
              trailing: Icon(Icons.edit),
              onTap: _showUserNameDialog,
            ),
            Divider(),
            ListTile(
              title: Text("IP Address: $ipAddress"),
              trailing: Icon(Icons.edit),
              onTap: _showIPDialog,
            ),
          ],
        ),
      ),
    );
  }
}

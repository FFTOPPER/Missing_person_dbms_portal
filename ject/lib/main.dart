import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ject/speechtext.dart';
import 'dart:convert'; // For handling JSON responses
import 'package:shared_preferences/shared_preferences.dart';
import 'upload.dart'; // Import the UploadPage
import 'whoisthis.dart'; // Import the WhoIsThisPage class for navigation
import 'task.dart'; // Import the task.dart file for navigation
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Animation
          AnimatedContainer(
            duration: Duration(seconds: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple, Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Scaling and Fading Text Animation
          Center(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  'STM-LOST-AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(2, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Amy";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _nameController.text = userName;
  }

  // Function to show the dialog box for IP input
  void _showIpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter IP Address'),
          content: TextField(
            controller: _ipController,
            decoration: InputDecoration(hintText: "Enter IP address"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Save the entered IP address silently without any message
                String ip = _ipController.text;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('ip_address', ip);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Example function to use the stored IP for HTTP requests
  Future<void> performSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    String baseUrl = prefs.getString('ip_address') ?? 'http://default.ip';

    final response = await http.get(
      Uri.parse('$baseUrl/api/search?q=$query'),
    );

    if (response.statusCode == 200) {
      // Handle the search results
      var data = jsonDecode(response.body);
      print(data); // For demonstration, replace with actual logic
    } else {
      print("Search failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Hi, ', // Static part of greeting
              style: TextStyle(color: Colors.black),
            ),
            Container(
              width: 100,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: TextStyle(color: Colors.black),
                onSubmitted: (value) {
                  setState(() {
                    userName = value.isEmpty ? "Amy" : value; // Update the name if submitted
                  });
                },
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              'STM-LostAI',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar with server integration
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.mic, color: Colors.grey[700]),
                    onPressed: () {
                      // Add your voice search functionality here
                    },
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                ),
                onSubmitted: (value) {
                  performSearch(value); // Trigger search on submission
                },
              ),
            ),
            SizedBox(height: 20),
            // Categories with Icons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1,
                children: [
                  CategoryBox(title: 'Add person', color: Colors.purple[100]!, icon: Icons.person_add),
                  CategoryBox(
                    title: 'Person identification',
                    color: Colors.pink[100]!,
                    icon: Icons.help_outline,
                    onTap: () {
                      // Navigate to the WhoIsThisPage when 'Person identification' is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WhoIsThisPage()), // Navigating to the WhoIsThisPage
                      );
                    },
                  ),
                  CategoryBox(
                    title: 'Task entering',
                    color: Colors.orange[100]!,
                    icon: Icons.add_task,
                    onTap: () {
                      // Navigate to the tasks.dart page when 'Task entering' is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SpeechToTextPage()), // Assuming TasksPage is the main widget in tasks.dart
                      );
                    },
                  ),
                  CategoryBox(title: 'Task viewing', color: Colors.yellow[100]!, icon: Icons.view_list,
                    onTap: () {
                      // Navigate to the tasks.dart page when 'Task entering' is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewTasksPage()), // Assuming TasksPage is the main widget in tasks.dart
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
            if (index == 2) {
              _showIpDialog(); // Show the dialog when the "IP" button is tapped
            }
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Reminder'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'IP'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
      ),
    );
  }
}

class CategoryBox extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  CategoryBox({required this.title, required this.color, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
              () {
            if (title == 'Add person') {
              // Navigate to the UploadPage when 'Add Person' is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadPage()), // Navigating to the UploadPage
              );
            } else {
              // Add API integration for each category when tapped (other categories)
              print('Category: $title tapped');
            }
          },
      child: Container(
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey[800]),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
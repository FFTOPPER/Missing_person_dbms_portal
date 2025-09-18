import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ject/exercise.dart';
import 'package:ject/stress.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'speechtext.dart';
import 'upload.dart';
import 'whoisthis.dart';
import 'task.dart';
import 'premium.dart'; // Import Premium Page
import 'profile.dart'; // Import Profile Page
import 'stress.dart';
import 'exercise.dart';

class CategoryItem {
  final String title;
  final Color color;
  final IconData icon;
  final Widget page;

  CategoryItem({
    required this.title,
    required this.color,
    required this.icon,
    required this.page,
  });
}

class CategoryBox extends StatelessWidget {
  final CategoryItem category;

  CategoryBox({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => category.page),
      ),
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, size: 40, color: Colors.black),
            SizedBox(height: 10),
            Text(
              category.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class NextScreen extends StatefulWidget {
  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  String userName = "Amy";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  int _selectedIndex = 0;
  List<CategoryItem> categories = [];
  List<CategoryItem> filteredCategories = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String ipAddress = '192.168.0.1';

  @override
  void initState() {
    super.initState();
    _nameController.text = userName;
    _speech = stt.SpeechToText();
    _initializeCategories();
    _loadIPAddress();
  }

  void _initializeCategories() {
    categories = [
      CategoryItem(
        title: 'Add person',
        color: Colors.purple[100]!,
        icon: Icons.person_add,
        page: UploadPage(),
      ),
      CategoryItem(
        title: 'Person identification',
        color: Colors.pink[100]!,
        icon: Icons.help_outline,
        page: WhoIsThisPage(),
      ),
      CategoryItem(
        title: 'Task entering',
        color: Colors.orange[100]!,
        icon: Icons.add_task,
        page: SpeechToTextPage(),
      ),
      CategoryItem(
        title: 'Task viewing',
        color: Colors.yellow[100]!,
        icon: Icons.view_list,
        page: ViewTasksPage(),
      ),
      CategoryItem(
        title: 'Stress Reliever',
        color: Colors.blue[100]!,  // Light blue for contrast
        icon: Icons.self_improvement,
        page: StressPage(),
      ),
      CategoryItem(
        title: 'Guided Relaxation',
        color: Colors.green[100]!, // Light green for variety
        icon: Icons.waves,
        page: ExercisePage(),
      ),
    ];
    filteredCategories = List.from(categories);
  }

  void _filterCategories(String query) {
    setState(() {
      filteredCategories = query.isEmpty
          ? List.from(categories)
          : categories
          .where((category) =>
          category.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech Status: $status'),
      onError: (error) => print('Speech Error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
            _filterCategories(result.recognizedWords);
          });
        },
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  Future<void> _loadIPAddress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ipAddress = prefs.getString('ip_address') ?? '192.168.0.1';
    });
  }

  Future<void> _saveIPAddress(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip_address', ip);
    setState(() {
      ipAddress = ip;
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

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: () {
                    _isListening ? _stopListening() : _startListening();
                  },
                ),
              ),
              onChanged: _filterCategories,
            ),
          ),
          Expanded(
            child: filteredCategories.isEmpty
                ? Center(child: Text("No results found"))
                : GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1,
              children: filteredCategories
                  .map((category) => CategoryBox(category: category))
                  .toList(),
            ),
          ),
        ],
      ),
      Center(child: Text("IP Settings Page")),
      Center(child: Text("Reminder Page")),
      ProfilePage(), // Redirect to Profile Page
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Hi, $userName', style: TextStyle(color: Colors.black)),
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
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          if (index == 1) {
            _showIPDialog();
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PremiumPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'IP'),
          BottomNavigationBarItem(icon: Icon(Icons.workspace_premium), label: 'Premium'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
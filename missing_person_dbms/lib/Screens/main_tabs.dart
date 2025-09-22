import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class MainTabs extends StatefulWidget {
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _serverIP = "";
  late AnimationController _iconController;
  late Animation<double> _bounceAnimation;

  final List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();
    _loadIP();

    _iconController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
    _iconController.repeat(reverse: true);

    // Define user-specific tabs
    _tabs.addAll([
      Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedIconWidget(icon: Icons.home, text: "Home"),
        ],
      )),
      Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedIconWidget(icon: Icons.search, text: "Search Missing Persons"),
        ],
      )),
      Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedIconWidget(icon: Icons.report, text: "Reports"),
        ],
      )),
      Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedIconWidget(icon: Icons.person, text: "Profile"),
        ],
      )),
    ]);
  }

  Future<void> _loadIP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverIP = prefs.getString('server_ip') ?? 'Not Set';
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Portal"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Text(
            "Server IP: $_serverIP",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class AnimatedIconWidget extends StatefulWidget {
  final IconData icon;
  final String text;
  AnimatedIconWidget({required this.icon, required this.text});

  @override
  _AnimatedIconWidgetState createState() => _AnimatedIconWidgetState();
}

class _AnimatedIconWidgetState extends State<AnimatedIconWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(seconds: 2), vsync: this);
    _bounce = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounce.value),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 80, color: Colors.blueAccent),
              SizedBox(height: 10),
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    widget.text,
                    textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue],
                  ),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/admin_signin.dart';
import 'Screens/admin_signup.dart';
import 'Screens/user_signin.dart';
import 'Screens/user_signup.dart';
import 'Screens/main_tabs.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() {
  runApp(MissingPersonApp());
}

class MissingPersonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Missing Person DBMS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(), // Start with SplashScreen
      routes: {
        '/user_signup': (context) => UserSignUp(),
        '/user_signin': (context) => UserSignIn(),
        '/admin_signup': (context) => AdminSignUp(),
        '/admin_signin': (context) => AdminSignIn(),
        '/main_tabs': (context) => MainTabs(),
      },
    );
  }
}

// Splash Screen with animated icon and text
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(seconds: 2), vsync: this);
    _bounceAnimation =
        Tween<double>(begin: 0, end: 20).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.bounceInOut,
        ));

    _controller.repeat(reverse: true);

    // Navigate to LoginSelectionPage after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginSelectionPage()));
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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_bounceAnimation.value),
                  child: Icon(Icons.person_search,
                      size: 100, color: Colors.white),
                );
              },
            ),
            SizedBox(height: 20),
            AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Missing Person\n   DBMS Portal',
                  textStyle: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                  colors: [
                    Colors.yellow,
                    Colors.orange,
                    Colors.red,
                    Colors.purple,
                    Colors.blue,
                  ],
                ),
                ColorizeAnimatedText(
                  'DBMS Portal',
                  textStyle: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w600),
                  colors: [
                    Colors.green,
                    Colors.cyan,
                    Colors.indigo,
                    Colors.pink,
                    Colors.amber,
                  ],
                ),
              ],
              isRepeatingAnimation: true,
              repeatForever: true,
            ),
          ],
        ),
      ),
    );
  }
}

// Login Selection Page with animations and IP settings
class LoginSelectionPage extends StatelessWidget {
  final TextEditingController ipController = TextEditingController();

  Future<void> _saveIP(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', ip);
  }

  void _showIPDialog(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedIP = prefs.getString('server_ip') ?? '';
    ipController.text = savedIP;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Enter Server IP"),
        content: TextField(
          controller: ipController,
          decoration: InputDecoration(hintText: "e.g., 192.168.0.101"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (ipController.text.trim().isNotEmpty) {
                _saveIP(ipController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Server IP saved")));
              }
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
      appBar: AppBar(
        title: Text("Login Selection"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showIPDialog(context),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Flutter icon
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 20),
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, -value),
                  child: Icon(
                    Icons.person_search,
                    color: Colors.white,
                    size: 80,
                  ),
                );
              },
              onEnd: () {},
            ),
            SizedBox(height: 20),
            AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Select Login Type',
                  textStyle: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                  colors: [
                    Colors.red,
                    Colors.blue,
                    Colors.orange,
                    Colors.purple,
                  ],
                ),
              ],
              isRepeatingAnimation: true,
              repeatForever: true,
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user_signin');
              },
              style: ElevatedButton.styleFrom(
                  padding:
                  EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: Text(
                "User Login",
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin_signin');
              },
              style: ElevatedButton.styleFrom(
                  padding:
                  EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: Text(
                "Admin Login",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

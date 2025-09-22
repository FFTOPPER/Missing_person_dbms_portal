import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../utils/api_helper.dart';
import 'admin_main_tabs.dart';
import 'admin_signup.dart';

class AdminSignIn extends StatefulWidget {
  @override
  _AdminSignInState createState() => _AdminSignInState();
}

class _AdminSignInState extends State<AdminSignIn>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late AnimationController _iconController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
        duration: const Duration(seconds: 2), vsync: this);
    _bounceAnimation =
        Tween<double>(begin: 0, end: 20).animate(CurvedAnimation(
          parent: _iconController,
          curve: Curves.easeInOut,
        ));
    _iconController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String url = await ApiHelper.getFullUrl('login.php'); // dynamic IP
      try {
        var response = await http.post(Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": emailController.text.trim(),
              "password": passwordController.text.trim(),
              "user_type": "admin"
            }));

        var data = jsonDecode(response.body);

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'])));

        if (data['status'] == 'success') {
          // Navigate to Admin Main Tabs page after successful login
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => AdminMainTabs()));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error connecting to server")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade200, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_bounceAnimation.value),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 100,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'Admin Sign-In',
                    textStyle: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                    colors: [
                      Colors.yellow,
                      Colors.orange,
                      Colors.red,
                      Colors.purple,
                      Colors.blue,
                    ],
                  ),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      FadeInField(
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          validator: (value) =>
                          !value!.contains('@') ? 'Enter valid email' : null,
                        ),
                      ),
                      SizedBox(height: 15),
                      FadeInField(
                        child: TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          obscureText: true,
                          validator: (value) => value!.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                        ),
                      ),
                      SizedBox(height: 25),
                      FadeInField(
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 5,
                          ),
                          child: Text(
                            "Sign In",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeInField(
                        child: TextButton(
                          onPressed: () {
                            // Navigate to Admin Sign-Up page
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AdminSignUp()));
                          },
                          child: Text(
                            "Don't have an account? Sign Up",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Fade-in animation widget for form fields and button
class FadeInField extends StatefulWidget {
  final Widget child;
  final int delay;

  FadeInField({required this.child, this.delay = 300});

  @override
  _FadeInFieldState createState() => _FadeInFieldState();
}

class _FadeInFieldState extends State<FadeInField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 800), vsync: this);
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}

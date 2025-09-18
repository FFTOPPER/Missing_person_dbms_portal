import 'package:chatbot_sos/chatbot_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'next_screen.dart';
import 'signup_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String errorMessage = "";

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    String savedEmail = prefs.getString('user_email') ?? "";
    String savedPassword = prefs.getString('user_password') ?? "";

    String enteredEmail = _emailController.text.trim();
    String enteredPassword = _passwordController.text.trim();

    if (enteredEmail == savedEmail && enteredPassword == savedPassword) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatbotScreen()));
    } else {
      setState(() {
        errorMessage = "Invalid email or password!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: "logo",
                  child: Icon(Icons.lock, size: 100, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text("Login", style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Enter email",
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.contains('@') ? null : "Enter a valid email",
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: "Enter password",
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: (value) => value!.length >= 6 ? null : "Password must be 6+ characters",
                      ),
                      SizedBox(height: 10),
                      Text(errorMessage, style: TextStyle(color: Colors.redAccent)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        ),
                        child: Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupPage())),
                  child: Text("Don't have an account? Sign up", style: TextStyle(color: Colors.tealAccent)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _signup() async {
    final prefs = await SharedPreferences.getInstance();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Store user credentials
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup Successful! You can now login.')),
    );

    // Navigate to login page after successful signup
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: "logo",
                  child: Icon(Icons.person_add, size: 100, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text("Sign Up", style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
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
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signup();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        ),
                        child: Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())),
                  child: Text("Already have an account? Log in", style: TextStyle(color: Colors.tealAccent)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:async';

class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  String _emergencyName = "John Doe";
  String _emergencyNumber = "9876543210";
  bool _showDanger = true;
  bool _showSupport = false;

  late AnimationController _dangerController;
  late AnimationController _supportController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  void _startAnimations() {
    _dangerController =
    AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..repeat(reverse: true);
    _supportController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.2).animate(_dangerController);

    Timer(Duration(seconds: 3), () {
      setState(() {
        _showDanger = false;
      });
      _supportController.forward();
    });

    Timer(Duration(seconds: 4), () {
      setState(() {
        _showSupport = true;
      });
    });
  }

  @override
  void dispose() {
    _dangerController.dispose();
    _supportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _showDanger ? 1.0 : 0.0,
              duration: Duration(seconds: 1),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 100,
                ),
              ),
            ),
            SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _showSupport ? 1.0 : 0.0,
              duration: Duration(seconds: 1),
              child: ScaleTransition(
                scale: _supportController.drive(
                  Tween<double>(begin: 0.5, end: 1.0),
                ),
                child: Icon(
                  Icons.volunteer_activism_rounded,
                  color: Colors.greenAccent,
                  size: 100,
                ),
              ),
            ),
            SizedBox(height: 30),
            AnimatedContainer(
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.8),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Emergency Contact",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "$_emergencyName",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "$_emergencyNumber",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

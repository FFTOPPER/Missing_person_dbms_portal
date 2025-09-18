import 'dart:async';
import 'package:flutter/material.dart';

class HealthInsightsPage extends StatefulWidget {
  @override
  _HealthInsightsPageState createState() => _HealthInsightsPageState();
}

class _HealthInsightsPageState extends State<HealthInsightsPage> {
  final List<Map<String, dynamic>> healthTips = [
    {'icon': Icons.local_drink, 'text': "Hydration is key! Drink more water."},
    {'icon': Icons.fastfood, 'text': "Avoid processed food for better health."},
    {'icon': Icons.directions_run, 'text': "Exercise at least 30 minutes daily."},
    {'icon': Icons.wb_sunny, 'text': "Get sunlight for vitamin D and mood boost!"},
    {'icon': Icons.local_hospital, 'text': "Regular check-ups can prevent major illnesses."},
    {'icon': Icons.favorite, 'text': "Laugh more! It’s good for your heart."},
  ];

  int _currentTipIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTipRotation();
  }

  void _startTipRotation() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % healthTips.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Health Insights"), backgroundColor: Colors.blue),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue.shade100, Colors.green.shade200]),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: Duration(seconds: 1),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                    .animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Card(
              key: ValueKey<int>(_currentTipIndex),
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: EdgeInsets.all(20),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      healthTips[_currentTipIndex]['icon'],
                      size: 80,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(height: 20),
                    Text(
                      healthTips[_currentTipIndex]['text'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
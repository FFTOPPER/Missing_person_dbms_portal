import 'package:flutter/material.dart';
import 'package:location/location.dart'; // Import location package
import 'settings.dart';
import 'chatbot_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NextScreen extends StatefulWidget {
  @override
  NextScreenState createState() => NextScreenState();
}

class NextScreenState extends State<NextScreen> {
  Location location = Location();
  String locationText = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  // Fetch user location
  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      LocationData locationData = await location.getLocation();
      setState(() {
        locationText =
        "Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}";
      });
    } catch (e) {
      setState(() {
        locationText = "Error getting location: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SOS-Chatbot"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatbotScreen()),
                );
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_police,
                  size: 100,
                  color: Colors.white,
                ),
              )
                  .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
                  .scaleXY(end: 1.1, duration: 500.ms)
                  .then()
                  .scaleXY(end: 1.0, duration: 500.ms),
            ),
            SizedBox(height: 20),
            Text(
              locationText,
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

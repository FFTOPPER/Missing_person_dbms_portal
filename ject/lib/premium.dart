import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'payment.dart';

class PremiumPage extends StatefulWidget {
  @override
  _PremiumPageState createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  int _currentIndex = 0;
  late Timer _timer;
  String _username = "User"; // Default name if none is found

  final List<Map<String, String>> premiumPlans = [
    {
      'title': 'Silver Plan',
      'price': '\$25/month',
      'features': '✔️ Person Identification: 28\n✔️ Task Scheduling: 28\n✔️ Device Limit: 1'
    },
    {
      'title': 'Gold Plan',
      'price': '\$70/3-month',
      'features': '✔️ Person Identification: 86\n✔️ Task Scheduling: 86\n✔️ Device Limit: 2'
    },
    {
      'title': 'Platinum Plan',
      'price': '\$135/6-month',
      'features': '✔️ Person Identification: 172\n✔️ Task Scheduling: 172\n✔️ Device Limit: 3'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _startAutoSlide();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? "User"; // Fetch saved username
    });
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % premiumPlans.length;
        });
      }
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
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: Text("Premium Membership"),
        backgroundColor: Colors.amber[800],
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Icon(Icons.workspace_premium_rounded, size: 80, color: Colors.amberAccent),
          SizedBox(height: 10),

          // Displaying "Hello, username!"
          Text(
            "Hello, $_username!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),

          SizedBox(height: 20),

          // Carousel with Flip Cards
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              enlargeCenterPage: true,
              autoPlay: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: premiumPlans.map((plan) {
              return FlipCard(
                direction: FlipDirection.HORIZONTAL,
                front: _buildPremiumBox(plan['title']!, plan['price']!, false),
                back: _buildPremiumBox(plan['features']!, "", true),
              );
            }).toList(),
          ),

          SizedBox(height: 30),

          // Subscribe Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage()));
            },
            child: Text("Subscribe Now", style: TextStyle(fontSize: 18, color: Colors.black)),
          ),

          SizedBox(height: 30),

          // Animated Hourglass & Text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitPouringHourGlassRefined(color: Colors.amber, size: 50.0),
              SizedBox(width: 20),
              Text(
                "Unlock Premium & Shine!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amberAccent),
              ),
              SizedBox(width: 20),
              SpinKitPouringHourGlassRefined(color: Colors.amber, size: 50.0),
            ],
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }

  // Premium Plan Box
  Widget _buildPremiumBox(String title, String subtitle, bool isBack) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isBack ? Colors.amberAccent : Colors.black87,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 10, spreadRadius: 3)],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: isBack ? 16 : 22, fontWeight: FontWeight.bold, color: isBack ? Colors.black : Colors.white),
              ),
              if (!isBack) ...[
                SizedBox(height: 10),
                Text(subtitle, style: TextStyle(fontSize: 18, color: Colors.white70)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

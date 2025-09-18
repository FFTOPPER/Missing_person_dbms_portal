import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 10).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text("Complete Your Payment"),
        backgroundColor: Colors.amber[800],
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Payment Icon
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animation.value),
                child: Icon(Icons.attach_money_rounded, size: 80, color: Colors.amberAccent),
              );
            },
          ),

          SizedBox(height: 20),

          Text(
            "Choose Your Payment Method",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),

          SizedBox(height: 20),

          // Payment Options Grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            children: [
              _buildPaymentOption(Icons.account_balance_wallet, "UPI"),
              _buildPaymentOption(Icons.credit_card, "Credit/Debit Card"),
              _buildPaymentOption(Icons.qr_code, "Scan QR Code"),
              _buildPaymentOption(Icons.account_balance, "Net Banking"),
            ],
          ),

          SizedBox(height: 20),

          // Pay Now Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              // Perform payment logic here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Processing Payment...")),
              );
            },
            child: Text(
              "Pay Now",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Payment Option Widget
  Widget _buildPaymentOption(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$title Selected")));
      },
      child: Card(
        color: Colors.amber[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.black),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

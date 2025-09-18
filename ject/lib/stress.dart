import 'package:flutter/material.dart';

class StressPage extends StatefulWidget {
  @override
  _StressPageState createState() => _StressPageState();
}

class _StressPageState extends State<StressPage> {
  final List<StressItem> stressItems = [
    StressItem(title: 'Meditation', icon: Icons.self_improvement, color: Colors.blue[100]!),
    StressItem(title: 'Music Therapy', icon: Icons.music_note, color: Colors.green[100]!),
    StressItem(title: 'Yoga', icon: Icons.spa, color: Colors.purple[100]!),
    StressItem(title: 'Deep Breathing', icon: Icons.air, color: Colors.orange[100]!),
    StressItem(title: 'Exercise', icon: Icons.fitness_center, color: Colors.red[100]!),
    StressItem(title: 'Healthy Diet', icon: Icons.local_dining, color: Colors.yellow[100]!),
    StressItem(title: 'Sleep Well', icon: Icons.nightlight_round, color: Colors.cyan[100]!),
    StressItem(title: 'Talk to a Friend', icon: Icons.chat, color: Colors.pink[100]!),
    StressItem(title: 'Positive Thinking', icon: Icons.wb_sunny, color: Colors.teal[100]!),
    StressItem(title: 'Reading', icon: Icons.menu_book, color: Colors.brown[100]!),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stress Reliever', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 tabs per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: stressItems.length,
                itemBuilder: (context, index) {
                  return StressBox(stressItem: stressItems[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StressItem {
  final String title;
  final IconData icon;
  final Color color;

  StressItem({required this.title, required this.icon, required this.color});
}

class StressBox extends StatelessWidget {
  final StressItem stressItem;

  StressBox({required this.stressItem});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${stressItem.title} selected!')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: stressItem.color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(stressItem.icon, size: 40, color: Colors.black),
            SizedBox(height: 10),
            Text(
              stressItem.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

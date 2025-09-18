import 'package:flutter/material.dart';

class ExercisePage extends StatefulWidget {
  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final List<Map<String, dynamic>> stressCategories = [
    {"title": "Acute Stress", "icon": Icons.flash_on, "color": Colors.red[100]},
    {"title": "Episodic Acute Stress", "icon": Icons.timer, "color": Colors.orange[100]},
    {"title": "Chronic Stress", "icon": Icons.healing, "color": Colors.yellow[100]},
    {"title": "Psychological Stress", "icon": Icons.psychology, "color": Colors.blue[100]},
    {"title": "Physical Stress", "icon": Icons.fitness_center, "color": Colors.green[100]},
    {"title": "Environmental Stress", "icon": Icons.park, "color": Colors.teal[100]},
    {"title": "Workplace Stress", "icon": Icons.business_center, "color": Colors.purple[100]},
    {"title": "Social Stress", "icon": Icons.group, "color": Colors.pink[100]},
    {"title": "Academic Stress", "icon": Icons.school, "color": Colors.indigo[100]},
    {"title": "Traumatic Stress", "icon": Icons.warning, "color": Colors.brown[100]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Guided Relaxation", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
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
              itemCount: stressCategories.length,
              itemBuilder: (context, index) {
                final category = stressCategories[index];
                return GestureDetector(
                  onTap: () {
                    // Handle tab click action (Navigate or Show Dialog)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${category['title']} tapped!")),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: category["color"],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(category["icon"], size: 40, color: Colors.black),
                        SizedBox(height: 10),
                        Text(
                          category["title"],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

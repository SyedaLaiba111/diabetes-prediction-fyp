import 'package:flutter/material.dart';

class DietPlanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dietTips = [
      "Eat plenty of vegetables and fruits",
      "Choose whole grains over refined grains",
      "Include lean proteins like fish, chicken, and legumes",
      "Limit sugary foods and beverages",
      "Reduce saturated and trans fats",
      "Stay hydrated and avoid excessive salt",
      "Maintain regular meal times",
      "Exercise regularly",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Healthy Diet Plan"),
        backgroundColor: Colors.teal[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: dietTips.length,
          separatorBuilder: (_, __) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: Colors.tealAccent.withOpacity(0.4),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.teal[700],
                  size: 30,
                ),
                title: Text(
                  dietTips[index],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[900],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'predict_page.dart';
import 'history.dart';
import 'profile.dart';
import 'DietPlanScreen.dart';  // <-- Import your new diet plan screen

class BottomNav extends StatefulWidget {
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late PredictionScreen home;
  late History history;
  late DietPlanScreen dietPlan;
  late Profile profile;

  @override
  void initState() {
    home = PredictionScreen();
    history = History();
    dietPlan = DietPlanScreen();
    profile = Profile();

    pages = [home, history,dietPlan, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff71CCD7), // Match login/signup background
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Colors.white, // Card-like background for inner content
              child: pages[currentTabIndex],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
            ),
          ],
        ),
        child: CurvedNavigationBar(
          backgroundColor: Color(0xff71CCD7), // Match login/signup
          color: Color(0xff5FBFDC),
          animationDuration: Duration(milliseconds: 300),
          index: currentTabIndex,
          height: 60,
          items: const [
            Icon(Icons.home, size: 30, color: Colors.black),
            Icon(Icons.history, size: 30, color: Colors.black),
            Icon(Icons.restaurant_menu, size: 30, color: Colors.black), // 4th icon for Diet Plan
            Icon(Icons.person, size: 30, color: Colors.black),

          ],
          onTap: (index) {
            setState(() {
              currentTabIndex = index;
            });
          },
        ),
      ),
    );
  }
}

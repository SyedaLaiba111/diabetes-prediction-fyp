import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:diabities/DietPlanScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import DietPlanScreen if in separate file, otherwise keep it below
// import 'diet_plan_screen.dart';

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _pregController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _bpController = TextEditingController();
  final _skinController = TextEditingController();
  final _insulinController = TextEditingController();
  final _bmiController = TextEditingController();
  final _dpfController = TextEditingController();
  final _ageController = TextEditingController();

  bool isLoading = false;
  String result = '';

  Future<void> predictDiabetes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      result = '';
    });

    try {
      final url = Uri.parse('https://59a6-39-49-145-37.ngrok-free.app/predict');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "features": [
            double.parse(_pregController.text),
            double.parse(_glucoseController.text),
            double.parse(_bpController.text),
            double.parse(_skinController.text),
            double.parse(_insulinController.text),
            double.parse(_bmiController.text),
            double.parse(_dpfController.text),
            double.parse(_ageController.text),
          ]
        }),
      );

      if (response.statusCode == 200) {
        final prediction = jsonDecode(response.body)['prediction'];
        final predictionText = prediction == 1
            ? "⚠️ High risk of Diabetes"
            : "✅ No Diabetes Detected";

        setState(() {
          result = predictionText;
        });

        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance.collection('predictions').add({
            "uid": user.uid,
            "timestamp": FieldValue.serverTimestamp(),
            "pregnancies": _pregController.text,
            "glucose": _glucoseController.text,
            "blood_pressure": _bpController.text,
            "skin_thickness": _skinController.text,
            "insulin": _insulinController.text,
            "bmi": _bmiController.text,
            "dpf": _dpfController.text,
            "age": _ageController.text,
            "result": predictionText,
          });
        }
      } else {
        setState(() {
          result = "Error: Server returned status code ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error occurred: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pregController.dispose();
    _glucoseController.dispose();
    _bpController.dispose();
    _skinController.dispose();
    _insulinController.dispose();
    _bmiController.dispose();
    _dpfController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Widget buildInput(String label, TextEditingController controller, String iconPath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              iconPath,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
          filled: true,
          fillColor: Colors.teal.shade50,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 100,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.2),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildInput("Pregnancies", _pregController, "assets/images/pregnancy.png"),
                      buildInput("Glucose", _glucoseController, "assets/images/glucose.png"),
                      buildInput("Blood Pressure", _bpController, "assets/images/blood_pressure.png"),
                      buildInput("Skin Thickness", _skinController, "assets/images/skin.png"),
                      buildInput("Insulin", _insulinController, "assets/images/insulin.png"),
                      buildInput("BMI", _bmiController, "assets/images/bmi.png"),
                      buildInput("Diabetes Pedigree Function", _dpfController, "assets/images/dpf.png"),
                      buildInput("Age", _ageController, "assets/images/age.png"),
                      SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade400,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                        ),
                        onPressed: isLoading ? null : predictDiabetes,
                        child: Text(
                          isLoading ? "Predicting..." : "PREDICT",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        result,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: result.startsWith('⚠️') ? Colors.red : Colors.teal.shade800,
                        ),
                      ),

                      // The new button that navigates to DietPlanScreen
                      if (result.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff71CCD7),
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DietPlanScreen()),
                              );
                            },
                            child: Text(
                              result.contains("High risk")
                                  ? "View Diet Plan for Diabetes"
                                  : "View Healthy Diet Plan",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

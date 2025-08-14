import 'package:flutter/material.dart';
import 'src/source/bp_pulse_chart.dart'; // Import your chart widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BP & Pulse Chart',
      home: Scaffold(
        appBar: AppBar(title: const Text('Blood Pressure & Pulse Chart')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BloodPressureChart(), // Use the widget here
        ),
      ),
    );
  }
}

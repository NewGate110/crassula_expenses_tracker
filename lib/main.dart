//This is the file that ties all the dart file in lib. the MAIN

import 'package:flutter/material.dart';

import 'views/tracker_view.dart';

void main() {
  runApp(const MoneyTrackerApp());
}

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TrackerView(),
    );
  }
}

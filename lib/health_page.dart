// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/firestore.dart';
import 'package:rpi_beefcake/widget_library.dart';

class HealthPage extends StatelessWidget {
  final FirebaseService db;
  const HealthPage({Key? key, required this.db}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Welcome to Flutter",
      home: Material(
        // Sleep Container
        child: SingleChildScrollView(
          child: Column(
            children: [
              FieldWithEnter(db: db, titleText: 'Sleep', fieldsCount: 3, boxText: const ['Hours of Sleep', 'Sleep Quality', 'Notes'], regex: const [r'/^\d*\.?\d*$/', r'/^\d*\.?\d*$/', r'.*'], dataEntry: db.addSleep),
            ]
          ),
        ),
      ),
    );
  }
}

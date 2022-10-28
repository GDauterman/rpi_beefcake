// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/firestore.dart';
import 'package:rpi_beefcake/widget_library.dart';

class HealthPage extends StatelessWidget {
  final FirebaseService db;
  const HealthPage({Key? key, required this.db}) : super(key: key);

  @override
  Widget build(BuildContext context){
    List<FieldOptions> sleepOptions = [
      FieldOptions(
        'Hours Slept',
        'Enter a number',
        TextInputType.number,
        r'^0*\d{1,2}(\.\d+)?$',
      ),
      FieldOptions(
        'Sleep Quality (0-100)',
        'Enter an integer from 0 to 100',
        TextInputType.number,
        r'^0*(\d{1,2}|100)$',
      ),
      FieldOptions(
        'Notes',
        '',
        TextInputType.text,
        r'.*?',
      )
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Welcome to Flutter",
      home: Material(
        // Sleep Container
        child: SingleChildScrollView(
          child: Column(
            children: [
              FieldWithEnter(db: db, titleText: 'Sleep', fieldOptions: sleepOptions, dataEntry: db.addSleep),
            ]
          ),
        ),
      ),
    );
  }
}

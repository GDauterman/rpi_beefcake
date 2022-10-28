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
      // TODO: replace regexp expressions with working ones
      // normal number regexp's don't work (specific ruleset?)
      FieldOptions(
        hint: 'Hours Slept',
        invalidText: 'Enter a number',
        validationRegex: r'(.*?)',
        keyboard: TextInputType.number
      ),
      FieldOptions(
        hint: 'Sleep Quality (0-100)',
        invalidText: 'Enter an integer from 0 to 100',
        validationRegex: r'(.*?)',
        keyboard: TextInputType.number
      ),
      FieldOptions(
        hint: 'Notes',
        invalidText: '',
        validationRegex: r'(.*?)',
        keyboard: TextInputType.text
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

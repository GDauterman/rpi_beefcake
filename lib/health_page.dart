// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/firestore.dart';
import 'package:rpi_beefcake/widget_library.dart';

class HealthPage extends StatelessWidget {
  final FirebaseService db;
  const HealthPage(this.db, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    List<FieldOptions> sleepOptions = [
      FieldOptions(
        hint: 'Hours Slept',
        invalidText: 'Enter a number',
        keyboard: TextInputType.number,
        regString: r'^0*\d{1,2}(\.\d+)?$',
      ),
      FieldOptions(
        hint: 'Sleep Quality (0-100)',
        invalidText: 'Enter an integer from 0 to 100',
        keyboard: TextInputType.number,
        regString: r'^0*(\d{1,2}|100)$',
      ),
      FieldOptions(
        hint: 'Notes',
      )
    ];
    return Material(
      // Sleep Container
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text('Sleep Entry'),
            FieldWithEnter(fieldOptions: sleepOptions, dataEntry: db.addSleep),
          ]
        ),
      ),
    );
  }
}

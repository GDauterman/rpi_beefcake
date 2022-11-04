// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/style_lib.dart';
import 'package:rpi_beefcake/widget_library.dart';
import 'firestore.dart';

List<String> exercisesList = <String>['Bench Press', 'Squat', 'Deadlift', 'Glute Spread'];

class FitnessPage extends StatefulWidget {
  FirebaseService db;
  FitnessPage(this.db, {Key? key}) : super(key: key);

  @override
  State<FitnessPage> createState() => _FitnessPage();
}

class _FitnessPage extends State<FitnessPage> {

  final CustDropdown exerciseDropdown = CustDropdown(exercisesList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 25, 0, 10),
                child: exerciseDropdown,
              ),
            ]
          )
        )
      )
    );
  }

}


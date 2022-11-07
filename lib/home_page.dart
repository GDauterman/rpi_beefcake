// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rpi_beefcake/style_lib.dart';

import 'firestore.dart';

enum ColTypes { Nutrition, Hydration, Sleep }

class HomePage extends StatelessWidget {
  FirebaseService db;
  HomePage(this.db, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DailyReport(db),
    );
  }
}

class DailyReport extends StatelessWidget {
  FirebaseService db;
  DailyReport(this.db, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 450,
      decoration: BoxDecoration(
        color: Colors.white24,
        border: Border.all(width: 5, color: Colors.black),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Daily Report',
            style: TextStyle(
              fontSize: 35,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Date: '+DateTime.now().month.toString()+'/'+DateTime.now().day.toString()+'/'+DateTime.now().year.toString(),
              style: TextStyle(
                fontSize: 20,
              ),
            )
          ),
          ProgressMeter(db, 'Hours Slept (hr)', 'hours', ColTypes.Sleep, 10),
          ProgressMeter(db, 'Calories Today', 'total_calories', ColTypes.Nutrition, 2000),
          ProgressMeter(db, 'Water Drank (oz)', 'amount', ColTypes.Hydration, 128)
        ],
      )
    );
  }
}

class ProgressMeter extends StatefulWidget {

  final FirebaseService db;
  final String title;
  final String field;
  final ColTypes col;
  final num goal;
  const ProgressMeter(this.db, this.title, this.field, this.col, this.goal, {Key? key}) : super(key: key);

  @override
  State<ProgressMeter> createState() => _ProgressMeter();
}

class _ProgressMeter extends State<ProgressMeter> {

  late double currentProgress;
  late double currentNum;

  void setLatestVal(num i) {
    setState(() {
      currentNum = i.toDouble();
      currentProgress=(i/widget.goal).toDouble();
    });
  }

  @override
  initState() {
    currentNum = 0;
    currentProgress = 0;
    switch(widget.col) {
      case ColTypes.Hydration:
        widget.db.getTodayHydration(widget.field, setLatestVal);
        break;
      case ColTypes.Nutrition:
        widget.db.getTodayNutrition(widget.field, setLatestVal);
        break;
      case ColTypes.Sleep:
        widget.db.getTodaySleep(widget.field, setLatestVal);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column (
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 15
          ),
        ),
        LinearProgressIndicator(
          value: currentProgress,
          backgroundColor: bc_style().accent1color,
          color: bc_style().accent2color,
        ),
        Text(
          currentNum.floor().toString()+'/'+widget.goal.floor().toString(),
          style: TextStyle(
            fontSize: 10,
          ),
        )
      ],
    );
  }
}


// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rpi_beefcake/style_lib.dart';

import 'firestore.dart';
import 'dart:math';

enum ColTypes { Nutrition, Hydration, Sleep }

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DailyReport(),
    );
  }
}

class DailyReport extends StatelessWidget {
  DailyReport({Key? key}) : super(key: key);
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
          ProgressMeter('Hours Slept (hr)', DBFields.durationS),
          ProgressMeter('Calories Today', DBFields.caloriesN),
          ProgressMeter('Water Drank (oz)', DBFields.quantityH)
        ],
      )
    );
  }
}

class ProgressMeter extends StatefulWidget {

  final String title;
  final DBFields field;
  const ProgressMeter(this.title, this.field, {Key? key}) : super(key: key);

  @override
  State<ProgressMeter> createState() => _ProgressMeter();
}

class _ProgressMeter extends State<ProgressMeter> {

  num barDec = 0;
  num progress = -1;
  num goal = 0;

  final userDocStream = FirebaseService().userDoc!.snapshots();

  void setLatestVal(num i) {
    setState(() {
      progress = i.toDouble();
      if(goal != -1)
        barDec= progress/goal;
    });
  }

  @override
  initState() {
    FirebaseService().getFieldAggSince(widget.field, setLatestVal, 2, FirebaseService.sumAgg);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userDocStream,
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          goal = -1;
          barDec = 0;
        } else {
          goal = snapshot.data![FirebaseService().dbGoalMap[widget.field]!] as num;
          if(progress != -1) {
            barDec = progress/goal;
          }
        }
        return Column (
          children: [
            Text(
              widget.title,
              style: TextStyle(
                  fontSize: 15
              ),
            ),
            LinearProgressIndicator(
              value: barDec.toDouble(),
              backgroundColor: bc_style().accent1color,
              color: bc_style().accent2color,
            ),
            Text(
              (goal == -1 || progress == -1) ? '--/--' : progress.floor().toString()+'/'+goal.toInt().toString(),
              style: TextStyle(
                fontSize: 10,
              ),
            )
          ],
        );
      }
    );

  }
}
// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rpi_beefcake/health_page.dart';
import 'package:rpi_beefcake/profile_page.dart';
import 'package:rpi_beefcake/style_lib.dart';
import 'package:rpi_beefcake/widget_library.dart';

import 'firestore.dart';
import 'dart:math';

enum ColTypes { Nutrition, Hydration, Sleep }
enum healthSubPages { home, sleep, nutrition, hydration, goals }

class HomePage extends StatelessWidget {
  static const _actionTitles = ["LogSleep", "logHydration", "logCalories", "logGoals"]; //set goals to be added
  healthSubPages curPage = healthSubPages.home;

  void _showAction(BuildContext context, int index) {
    Navigator.of(context).push(CustomPopupRoute(
      builder: (context) {
        switch (index) {
          case 0:
            return AlertDialog(
                content: SleepPage()
            );
          case 2:
            return AlertDialog(
                content: NutritionPage()
            );
          case 1:
            return AlertDialog(
                content: HydrationPage()
            );
          case 3:
            return AlertDialog(
                content: MeasurementPage()
            );
          default: //should never be triggered
            return AlertDialog(
                content: Text("Hello world :)")
            );
        }
      },
    ));
  }

  HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: DailyReport(),
        ),
      floatingActionButton: ExpandableFab(
      distance: 112.0,
      children: [
        ActionButton(
          onPressed: () => _showAction(context, 0),
          icon: const Icon(Icons.hotel),
        ),
        ActionButton(
          onPressed: () => _showAction(context, 1),
          icon: const Icon(Icons.local_drink),
        ),
        ActionButton(
          onPressed: () => _showAction(context, 2),
          icon: const Icon(Icons.fastfood),
        ),
        ActionButton(
          onPressed: () => _showAction(context, 3),
          icon: const Icon(Icons.monitor_weight),
        ),
      ],
    ),
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
          ProgressMeter('Water Drank (oz)', DBFields.quantityH),
          SingleValueUpdating(title: 'Today\'s Mean Weight', field: DBFields.weightM),
        ],
      )
    );
  }
}

class SingleValueUpdating extends StatefulWidget {
  String title;
  DBFields field;
  IconData? icon;

  SingleValueUpdating({Key? key, required this.title, required this.field, this.icon}) : super(key: key);

  @override
  State<SingleValueUpdating> createState() => _SingleValueUpdating();
}

class _SingleValueUpdating extends State<SingleValueUpdating> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService().userDoc!.collection('raw_graph_points').doc(FirebaseService.getDateDocName(DateTime.now())).snapshots(),
      builder: (context, snapshot) {
        String presentString = 'loading';
        if(snapshot.hasData) {
          presentString = widget.title + ': ';
          if(snapshot.data != null && snapshot.data!.data() != null && snapshot.data!.data()!.keys.contains(FirebaseService().dbPlotYMap[widget.field]!)) {
            presentString += snapshot.data!.get(FirebaseService().dbPlotYMap[widget.field]!).toStringAsFixed(1);
            presentString += " " + FirebaseService().dbUnitMap[widget.field]!;
          } else {
            presentString += 'no data';
          }
        }
        return Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Text(presentString),
        );
      },
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

  void setGoal(num i) {
    setState(() {
      goal = i.toDouble();
      if(progress != -1)
        barDec= progress/goal;
    });
  }

  @override
  initState() {
    FirebaseService().userDoc!.get().then((value) {
      setGoal(value[FirebaseService().dbGoalMap[widget.field]!]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService().userDoc!.collection('raw_graph_points').doc(FirebaseService.getDateDocName(DateTime.now())).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData || snapshot.data!.data() == null) {
          progress = -1;
          barDec = 0;
        } else {
          progress = snapshot.data!.data()![FirebaseService().dbPlotYMap[widget.field]!] as num;
          if(goal != -1) {
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

class HydrationPage extends StatelessWidget {
  HydrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    List<FieldOptions> hydrationOptions = [
      FieldOptions(
        hint: 'oz of liquid',
        invalidText: 'Enter a number',
        keyboard: TextInputType.number,
        regString: r'^0*\d+(\.\d+)?$',
      ),
    ];
    return Material(
      // Sleep Container
      child: SingleChildScrollView(
        child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top:20),
                child: Text(
                  'Hydration Entry',
                  style: TextStyle(
                      fontSize: 35
                  ),
                ),
              ),
              FieldWithEnter(fieldOptions: hydrationOptions, dataEntry: FirebaseService().addHydration),
            ]
        ),
      ),
    );
  }
}

class NutritionPage extends StatelessWidget {
  NutritionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    List<FieldOptions> sleepOptions = [
      FieldOptions(
        hint: 'Food',
        invalidText: 'Enter name of food',
        keyboard: TextInputType.text,
        regString: r'.+',
      ),
      FieldOptions(
        hint: 'Total Calories',
        invalidText: 'Enter a whole number',
        keyboard: TextInputType.number,
        regString: r'\d+',
      ),
      FieldOptions(
        hint: 'Total Carbohydrates',
        invalidText: 'Enter a whole number',
        keyboard: TextInputType.number,
        regString: r'\d+',
      ),
      FieldOptions(
        hint: 'Total Fats',
        invalidText: 'Enter a whole number',
        keyboard: TextInputType.number,
        regString: r'\d+',
      ),
      FieldOptions(
        hint: 'Total Protein',
        invalidText: 'Enter a whole number',
        keyboard: TextInputType.number,
        regString: r'\d+',
      ),
    ];
    return Material(
      // Sleep Container
      child: SingleChildScrollView(
        child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top:20),
                child: Text(
                  'Nutrition Entry',
                  style: TextStyle(
                      fontSize: 35
                  ),
                ),
              ),
              FieldWithEnter(fieldOptions: sleepOptions, dataEntry: FirebaseService().addNutrition),
            ]
        ),
      ),
    );
  }
}

class SleepPage extends StatelessWidget {
  SleepPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<FieldOptions> sleepOptions = [
      FieldOptions(
        hint: 'Hours Slept',
        invalidText: 'Enter  number',
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
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Sleep Entry',
                  style: TextStyle(
                      fontSize: 35
                  ),
                ),
              ),
              FieldWithEnter(fieldOptions: sleepOptions,
                  dataEntry: FirebaseService().addSleep),
            ]
        ),
      ),
    );
  }
}
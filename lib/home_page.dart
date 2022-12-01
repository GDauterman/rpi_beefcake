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

/// Stateless widget representing the homepage of our app
class HomePage extends StatelessWidget {

  HomePage({Key? key}) : super(key: key);

  void _showAction(BuildContext context, int index) {
    Navigator.of(context).push(CustomPopupRoute(
      builder: (context) {
        // builds popups of different logging pages
        switch (index) {
          case 0:
            return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.background,
                content: SleepPage());
          case 2:
            return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.background,
                content: NutritionPage());
          case 1:
            return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.background,
                content: HydrationPage());
          case 3:
            return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.background,
                content: MeasurementPage());
          default: //should never be triggered
            return AlertDialog(content: Text("Hello world :)"));
        }
      },
    ));
  }

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

/// StatelessWidget that represents the box in the middle of the page
class DailyReport extends StatelessWidget {
  DailyReport({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        height: 450,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          border: Border.all(width: 3, color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Daily Report', style: Theme.of(context).textTheme.headline3),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                    'Date: ' +
                        DateTime.now().month.toString() +
                        '/' +
                        DateTime.now().day.toString() +
                        '/' +
                        DateTime.now().year.toString(),
                    style: Theme.of(context).textTheme.headline4)),
            SizedBox(height: 25),
            ProgressMeter('Hours Slept (hr): ', DBFields.durationS),
            ProgressMeter('Calories Today: ', DBFields.caloriesN),
            ProgressMeter('Water Drank (oz): ', DBFields.quantityH),
            SingleValueUpdating(
                title: 'Today\'s Mean Weight:', field: DBFields.weightM),
          ],
        ));
  }
}

/// StatefulWidget that represents the daily update row of a single field
///
/// Specifically shows a single value
///
/// State depends on changing log values
class SingleValueUpdating extends StatefulWidget {
  /// Title to be used for this row
  String title;
  /// Field to be grabbed for this row
  DBFields field;
  /// Optional icon to be shown
  IconData? icon;

  SingleValueUpdating(
      {Key? key, required this.title, required this.field, this.icon})
      : super(key: key);

  @override
  State<SingleValueUpdating> createState() => _SingleValueUpdating();
}

/// Underlying implementation of SingleValueUpdating
class _SingleValueUpdating extends State<SingleValueUpdating> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService()
          .userDoc!
          .collection('raw_graph_points')
          .doc(FirebaseService.getDateDocName(DateTime.now()))
          .snapshots(),
      builder: (context, snapshot) {
        String presentString = 'loading';
        if (snapshot.hasData) {
          presentString = widget.title + "  ";
          if (snapshot.data != null &&
              snapshot.data!.data() != null &&
              snapshot.data!
                  .data()!
                  .keys
                  .contains(widget.field.getRawPlotStr)) {
            presentString += snapshot.data!
                .get(widget.field.getRawPlotStr)
                .toStringAsFixed(1);
            presentString += " " + widget.field.getUnits;
          } else {
            presentString += 'no data';
          }
        }
        return SizedBox(
          width: 280, //boxWidth = 300, 20 px padding preferred
          height: 60,
          child: Row(
            children: [
              SizedBox(width: 20),
              Text(
                presentString,
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// StatefulWidget that represents the daily update row of a single field
///
/// Specifically shows a value compared with its goal, along with a progressbar
///
/// State depends on changing log values
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
      if (progress != -1) barDec = progress / goal;
    });
  }

  @override
  initState() {
    FirebaseService().userDoc!.get().then((value) {
      setGoal(value[widget.field.getGoalStr]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseService()
            .userDoc!
            .collection('raw_graph_points')
            .doc(FirebaseService.getDateDocName(DateTime.now()))
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            progress = -1;
            barDec = 0;
          } else {
            progress = snapshot.data!
                .data()![widget.field.getRawPlotStr] as num;
            if (goal != -1) {
              barDec = progress / goal;
            }
          }
          return SizedBox(
            width: 280, //boxWidth = 300, 20 px padding preferred
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(width: 20),
                    Text(widget.title,
                        style: Theme.of(context)
                            .textTheme
                            .headline2
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Text(
                        (goal == -1 || progress == -1)
                            ? '--/--'
                            : progress.floor().toString() +
                                '/' +
                                goal.toInt().toString(),
                        style: Theme.of(context).textTheme.headline2),
                  ],
                ),
                Row(
                  children: [
                    CircularProgressIndicator(
                      value: barDec.toDouble(),
                      backgroundColor: Colors.grey[200],
                      color: Theme.of(context).colorScheme.primary,
                      semanticsLabel: 'Hours Slept',
                    ),
                    SizedBox(width: 20)
                  ],
                ),
              ],
            ),
          );
        });
  }
}
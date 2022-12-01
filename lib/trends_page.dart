// ignore_for_file: prefer_const_constructors
import 'dart:core';
import 'dart:math';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rpi_beefcake/fitness_page.dart';

import 'firestore.dart';

/// StatefulWidget representing the trends page of the app
class TrendsPage extends StatefulWidget {
  const TrendsPage({Key? key}) : super(key: key);

  @override
  State<TrendsPage> createState() => _TrendsPage();
}

/// Underlying representation of TrendsPage
class _TrendsPage extends State<TrendsPage> {

  late DropdownMenuItem<DBFields> curItem;
  late DBFields curField;

  late DropdownMenuItem<int> exItem;
  int ?exIdx;

  List<DropdownMenuItem<DBFields>> genList = [];
  List<DropdownMenuItem<int>> exerciseList = [];

  static const List<int> possibleIntervals = [
    1,
    2,
    3,
    5,
    10,
    25,
    50,
    100,
    200,
    250,
    500,
    1000,
    2000,
    10000,
    20000,
    100000,
    200000,
    1000000,
    2000000,
    10000000,
    20000000,
    100000000,
    200000000,
    1000000000,
    2000000000,
    10000000000,
    20000000000,
    100000000000,
    200000000000,
  ];

  final List<FlSpot> pointsTest = [
    FlSpot(0, 1),
    FlSpot(1, 1),
    FlSpot(2, 3),
    FlSpot(4, 2),
    FlSpot(5, 1),
    FlSpot(6, 4),
    FlSpot(8, 0),
  ];

  List<FlSpot>? points;
  List<FlSpot>? trendpoints;
  num goal = -1;
  num xmin = 0;
  num xmax = 1;
  num ymin = 0;
  num ymax = 0;
  num xinterval = 1;
  num yinterval = 1;
  num trendm = 0;
  num trendb = 0;

  List<DocumentSnapshot> historyDocs = [];
  List<Widget> historyRows = [];

  void getGoal(num ngoal) {
    setState(() {
      goal = ngoal;
    });
  }

  void queryForNewField() {
    print('starting query');
    if(curField != DBFields.exercise || exIdx != null) {
      points = [];
      historyDocs = [];
      historyRows = [];
      FirebaseService()
          .dbColMap[curField]!
          .orderBy('time_logged', descending: true)
          .get()
          .then(updateHistory);
      FirebaseService().getRawPlotPoints(curField, getPoints, 10, exIdx);
      if(curField != DBFields.exercise) {
        trendm = FirebaseService()
            .trendsDoc!
            .get(curField.getTrendsStr[0]);
        trendb = FirebaseService()
            .trendsDoc!
            .get(curField.getTrendsStr[1]);
      } else {
        trendb = -999999;
        trendm = 0;
      }
      if (curField != DBFields.exercise) {
        FirebaseService().userDoc!.get().then((value) {
          setState(() {
            goal = value[curField.getGoalStr];
          });
        });
      }
    }
    print('ending query');
    // List<String> trendStr = curField == DBFields.exercise ? [FirebaseService().getExerciseFields()[exIdx!]+"_m", FirebaseService().getExerciseFields()[exIdx!]+"_m"] : FirebaseService().dbTrendMap[curField]!;
  }

  void updateHistory(QuerySnapshot<Object?> value) {
    setState(() {
      String? fieldStr;
      if (curField == DBFields.exercise) {
        fieldStr = FirebaseService().getExerciseFields()[exIdx!];
      } else {
        fieldStr = curField.getFieldStr;
      }
      for (int i = 0; i < value.docs.length; i++) {
        DocumentSnapshot tempDoc = value.docs[i];
        Map<String, dynamic> tempData = tempDoc.data() as Map<String, dynamic>;
        if (tempData.keys.contains(fieldStr) && tempData[fieldStr] != -1) {
          historyDocs.add(tempDoc);
          historyRows
              .add(HistoryRow(field: curField, doc: tempDoc, exIdx: exIdx));
          // historyRows.add(Text('balls'));
        }
      }
    });
  }

  List<num> getIntervalRate(num min, num max, int intervalCount) {
    int? minDiff;
    int minVal = 0;
    for (int i = 0; i < possibleIntervals.length; i++) {
      int curDiff =
          (((max - min) / possibleIntervals[i]).floor() - intervalCount).abs();
      if (minDiff == null || curDiff < minDiff) {
        minDiff = curDiff;
        minVal = i;
      }
    }
    num finalInterval = possibleIntervals[minVal];
    num newMin = (min / finalInterval).floor() * finalInterval;
    num newMax = (max / finalInterval).ceil() * finalInterval;

    return [newMin, newMax, finalInterval];
  }

  void getPoints(List<dynamic> newPoints) {
    setState(() {
      xmin = newPoints[0] as num;
      xmax = newPoints[1] as num;
      ymin = newPoints[2] as num;
      ymax = newPoints[3] as num;

      points = newPoints[4].cast<FlSpot>();

      if (points != null && points!.isNotEmpty) {
        List<num> yres = getIntervalRate(ymin, ymax, 4);
        List<num> xres = getIntervalRate(xmin, xmax, 6);
        xmin = xres[0];
        xmax = xres[1];
        xinterval = xres[2];
        ymin = yres[0];
        ymax = yres[1];
        yinterval = yres[2];

        setTrendline();
      }
    });
  }

  void setTrendline() {
    double lineOffset = 0.1;
    trendpoints = [
      FlSpot((xmin - lineOffset), (trendm * (xmin - lineOffset) + trendb)),
      FlSpot((xmax + lineOffset), (trendm * (xmax + lineOffset) + trendb)),
    ];
  }

  static Widget getUnitAxisTickVals(double value, TitleMeta meta) {
    return SideTitleWidget(
      // angle: -pi/2,
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString()
          //style: COLOR: text style for individual axis ticks
          ),
    );
  }

  static Widget getDateAxisTickVals(double value, TitleMeta meta) {
    DateTime xdt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        "${xdt.month}/${xdt.day}",
        //style: COLOR: text style for individual axis ticks
      ),
    );
  }

  @override
  initState() {
    super.initState();

    print("staritng to add to genlist");
    for (int i = 0; i < DBFields.values.length; i++) {
      if(DBFields.values[i].getTitle == '') {
        continue;
      }
      print(DBFields.values[i].getTitle);
      DropdownMenuItem<DBFields> ddmiVal = DropdownMenuItem<DBFields>(
          child: Text(DBFields.values[i].getTitle),
          value: DBFields.values[i]);
      genList.add(ddmiVal);
    }

    for (int i = 0; i < exercisesList.length; i++) {
      DropdownMenuItem<int> ddmiExercise = DropdownMenuItem<int>(
          value: i,
          child: Text(FirebaseService().getExerciseTitles()[i]));
      exerciseList.add(ddmiExercise);
    }

    curItem = genList[0];
    curField = curItem.value!;

    exItem = exerciseList[0];
    exIdx = null;
    queryForNewField();

    print(genList.where((DropdownMenuItem<DBFields> item) {
      return item.value == curItem;
    }).length);
  }

  @override
  Widget build(BuildContext context) {
    DropdownButton genDropdown = DropdownButton(
      items: genList,
      hint: Text('Type of Feedback'),
      value: curField,
      onChanged: ((val){
        setState(() {
          curField = val;
          if(curField == DBFields.exercise)
            exIdx = 0;
          queryForNewField();
        });
      }),
    );
    DropdownButton exDropdown = DropdownButton(
      items: exerciseList,
      hint: Text('Type of Feedback'),
      value: exIdx,
      onChanged: ((val){
        setState(() {
          exIdx = val;
          queryForNewField();
        });
      }),
    );
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Select your Metric', style: Theme.of(context).textTheme.headline4),
            genDropdown,
            exIdx == null
                ? SizedBox.shrink()
                : exDropdown,
            SizedBox(height: 30),
            SizedBox(
              width: 350,
              height: 275,
              child: (points == null || points!.length < 2)
                  ? Center(
                      child: Text('Not enough logged data in the last 7 days'))
                  : LineChart(
                      swapAnimationDuration: Duration(milliseconds: 150),
                      swapAnimationCurve: Curves.linear,
                      LineChartData(
                        minX: xmin.toDouble(),
                        maxX: xmax.toDouble(),
                        minY: ymin.toDouble(),
                        maxY: ymax.toDouble(),
                        borderData: FlBorderData(
                            border: Border.all(
                                color: Colors
                                    .black // COLOR: colors of each individual border (also width)
                                )),
                        clipData: FlClipData(
                          top: true,
                          bottom: true,
                          left: true,
                          right: true,
                        ),
                        extraLinesData: ExtraLinesData(
                            horizontalLines: (goal > ymin && goal < ymax)
                                ? [
                                    HorizontalLine(
                                      y: goal.toDouble(),
                                      color: Colors
                                          .red, //COLOR: color of goal line
                                    )
                                  ]
                                : []),
                        gridData: FlGridData(
                          drawHorizontalLine: false,
                          drawVerticalLine: false,
                        ),
                        titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                  'Date'), // COLORS: Text widget for x axis title
                              axisNameSize: 22,
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: getDateAxisTickVals,
                                interval: xinterval.toDouble(),
                              ),
                            ),
                            leftTitles: AxisTitles(
                              axisNameWidget: Text(curField.getTitle), // COLORS: Text widget for x axis title
                              axisNameSize: 22,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                getTitlesWidget: getUnitAxisTickVals,
                                interval: yinterval.toDouble(),
                                // interval: (ymax-ymin).toDouble()
                              ),
                            ),
                            rightTitles: AxisTitles(),
                            topTitles: AxisTitles()),
                        lineBarsData: [
                          LineChartBarData(
                            spots: points,
                            barWidth: 4.5,
                            isCurved: false,
                            // dotData: FlDotData(
                            //   show: false,
                            // ),
                          ),
                          LineChartBarData(
                            spots: trendpoints,
                            color:
                                Colors.greenAccent, //COLOR: color of trend line
                            dotData: FlDotData(
                              show: false,
                            ),
                          )
                        ],
                      ),
                    ),
            ),
            historyRows.isNotEmpty
                ? Expanded(
                    child: ListView(children: historyRows),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class HistoryRow extends StatelessWidget {
  final DBFields field;
  final DocumentSnapshot doc;
  final int? exIdx; // index of exercise if exercise is the field
  const HistoryRow(
      {required this.field, required this.doc, this.exIdx, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
    Timestamp ts = docData['time_logged'];
    String tstr = DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch)
        .toString()
        .substring(5, 16);
    bool isFood = false;
    String title = '';
    String val = '';
    if (field != DBFields.exercise) {
      isFood = (field == DBFields.caloriesN ||
          field == DBFields.carbsN ||
          field == DBFields.fatN ||
          field == DBFields.proteinN);
      String fieldName = field.getFieldStr;
      title = (isFood
          ? docData['food_name'].toString()
          : field.getTitle);
      val = (docData[fieldName]).toStringAsFixed(1);
    }
    if (field == DBFields.exercise) {
      num maxVal = 0;
      title = FirebaseService().getExerciseTitles()[exIdx!];
      List<num> weights = docData['weights'];
      List<num> reps = docData['reps'];
      for (int i = 0; i < docData['setCount']; i++) {
        maxVal = max(maxVal, weights[i] / (1.0278 - (0.0278 * reps[i])));
      }
      val = maxVal.toStringAsFixed(1);
    }
    return GestureDetector(
        child: Container(
            child: SizedBox(
      height: 70,
      width: 350,
      child: Padding(
        padding: EdgeInsets.all(15),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 23),
                ),
                Text(tstr, style: TextStyle(fontSize: 10))
              ]),
          Text(
            val,
            style: TextStyle(fontSize: 35),
          )
        ]),
      ),
    )));
  }
}

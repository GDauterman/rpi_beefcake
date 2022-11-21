// ignore_for_file: prefer_const_constructors
import 'dart:core';
import 'dart:math';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rpi_beefcake/fitness_page.dart';

import 'firestore.dart';

class TrendsPage extends StatefulWidget {
  const TrendsPage({Key? key}) : super(key: key);

  @override
  State<TrendsPage> createState() => _TrendsPage();
}

class _TrendsPage extends State<TrendsPage> {
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
    1000
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

  late final List<DropDownValueModel> dbDropDownList;
  late List<DropDownValueModel> dbDropDownListExercise;
  final SingleValueDropDownController ddController =
      SingleValueDropDownController();
  final SingleValueDropDownController ddexController =
      SingleValueDropDownController();

  DBFields curField = DBFields.caloriesN;
  int? exIdx;

  List<DocumentSnapshot> historyDocs = [];
  List<Widget> historyRows = [];

  void getGoal(num ngoal) {
    setState(() {
      goal = ngoal;
    });
  }

  void queryForNewField() {
    points = [];
    historyDocs = [];
    historyRows = [];
    FirebaseService()
        .dbColMap[curField]!
        .orderBy('time_logged', descending: true)
        .get()
        .then(updateHistory);
    FirebaseService().getRawPlotPoints(curField, getPoints, 10, exIdx);
    trendm = FirebaseService()
        .trendsDoc!
        .get(FirebaseService().dbTrendMap[curField]![0]);
    trendb = FirebaseService()
        .trendsDoc!
        .get(FirebaseService().dbTrendMap[curField]![1]);
    if (curField != DBFields.exercise) {
      FirebaseService().userDoc!.get().then((value) {
        setState(() {
          goal = value[FirebaseService().dbGoalMap[curField]!];
        });
      });
    }
    // List<String> trendStr = curField == DBFields.exercise ? [FirebaseService().getExerciseFields()[exIdx!]+"_m", FirebaseService().getExerciseFields()[exIdx!]+"_m"] : FirebaseService().dbTrendMap[curField]!;
  }

  void updateHistory(QuerySnapshot<Object?> value) {
    setState(() {
      String? fieldStr;
      if (curField == DBFields.exercise) {
        fieldStr = FirebaseService().getExerciseFields()[exIdx!];
      } else {
        fieldStr = FirebaseService().dbFieldMap[curField]!;
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
        List<num> yres = getIntervalRate(ymin, ymax, 6);
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
    double lineOffset = 5;
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
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        "${value.toString().substring(4, 6)}/${value.toString().substring(6, 8)}",
        //style: COLOR: text style for individual axis ticks
      ),
    );
  }

  @override
  initState() {
    super.initState();
    dbDropDownList = [];
    List<DBFields> titledFields = FirebaseService().dbTitleMap.keys.toList();
    for (int i = 0; i < titledFields.length; i++) {
      DropDownValueModel ddvmVal = DropDownValueModel(
          name: FirebaseService().dbTitleMap[titledFields[i]]!,
          value: titledFields[i]);
      dbDropDownList.add(ddvmVal);
      if (ddvmVal.value == DBFields.caloriesN) {
        ddController.dropDownValue = ddvmVal;
        queryForNewField();
      }
    }
    dbDropDownListExercise = [];
    for (int i = 0; i < exercisesList.length; i++) {
      DropDownValueModel ddvmExercise = DropDownValueModel(
          name: FirebaseService().getExerciseTitles()[i], value: i);
      dbDropDownListExercise.add(ddvmExercise);
      if (i == 0) ddexController.dropDownValue = ddvmExercise;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Select your Metric', style: TextStyle(fontSize: 20)),
            DropDownTextField(
              dropDownList: dbDropDownList,
              controller: ddController,
              enableSearch: true,
              dropDownItemCount: 4,
              onChanged: ((val) {
                setState(() {
                  if (val is! String) curField = val.value;
                  if (curField == DBFields.exercise) {
                    exIdx = 0;
                  } else {
                    exIdx = null;
                  }
                  points = null;
                  queryForNewField();
                });
              }),
            ),
            exIdx == null
                ? SizedBox.shrink()
                : DropDownTextField(
                    dropDownList: dbDropDownListExercise,
                    controller: ddexController,
                    enableSearch: true,
                    dropDownItemCount: 4,
                    onChanged: ((val) {
                      setState(() {
                        exIdx = val.value;
                        points = null;
                        queryForNewField();
                      });
                    }),
                  ),
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
                              axisNameWidget: Text(FirebaseService().dbTitleMap[
                                  curField]!), // COLORS: Text widget for x axis title
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
                            isCurved: true,
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
      String fieldName = FirebaseService().dbFieldMap[field]!;
      title = (isFood
          ? docData['food_name'].toString()
          : FirebaseService().dbTitleMap[field]!);
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

// ignore_for_file: prefer_const_constructors
import 'dart:math';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'firestore.dart';

class TrendsPage extends StatefulWidget {
  const TrendsPage({Key? key}) : super(key: key);

  State<TrendsPage> createState() => _TrendsPage();
}

class _TrendsPage extends State<TrendsPage> {

  final List<FlSpot> pointsTest = [
    FlSpot(0,1),
    FlSpot(1,1),
    FlSpot(2,3),
    FlSpot(4,2),
    FlSpot(5,1),
    FlSpot(6,4),
    FlSpot(8,0),
  ];
  List<FlSpot>? points;
  num goal = -1;
  num xmin = 0;
  num xmax = 1;
  num ymin = 0;
  num ymax = 0;
  late final List<DropDownValueModel> dbDropDownList;
  final SingleValueDropDownController ddController = SingleValueDropDownController();
  DBFields curField = DBFields.caloriesN;

  void getGoal(num ngoal) {
    setState(() {
      goal = ngoal;
    });
  }

  void getPoints(List<dynamic> newPoints) {
    setState(() {
      print('start');
      xmin = newPoints[0] as num;
      xmax = newPoints[1] as num;
      ymin = newPoints[2] as num;
      ymax = newPoints[3] as num;
      print(ymin);

      // num xtotal = xmax - xmin;
      // xmax += 0.1*xtotal;
      // xmin -= 0.1*xtotal;
      //
      // num ytotal = ymax - ymin;
      // ymax += 0.1*ytotal;
      // ymin -= 0.1*ytotal;
      print(ymin);

      points = newPoints[4].cast<FlSpot>();
      print('end');
    });
  }

  static Widget getUnitAxisTickVals(double value, TitleMeta meta) {
    return SideTitleWidget(
      // angle: -pi/2,
      axisSide: meta.axisSide,
      child: Text(
        value.toString().substring(0,value.toString().length-2),
      ),
    );
  }

  static Widget getDateAxisTickVals(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toString().substring(4,6) + "/" + value.toString().substring(6,8),
      ),
    );
  }

  @override
  initState() {
    super.initState();
    dbDropDownList = [
    ];
    List<DBFields> titledFields = FirebaseService().dbTitleMap.keys.toList();
    for(int i = 0; i < titledFields.length; i++) {
      DropDownValueModel temp_ddvm = DropDownValueModel(name: FirebaseService().dbTitleMap[titledFields[i]]!, value: titledFields[i]);
      dbDropDownList.add(temp_ddvm);
      if(temp_ddvm.value == DBFields.caloriesN) {
        ddController.dropDownValue = temp_ddvm;
        FirebaseService().getRawPlotPoints(curField, getPoints, 7);
        FirebaseService().userDoc!.get().then((value) {
          setState((){goal = value[FirebaseService().dbGoalMap[curField]!];});
        });
      }
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
                  if(!(val is String))
                    curField = val.value;
                  points = null;
                  FirebaseService().getRawPlotPoints(curField, getPoints, 7);
                  FirebaseService().userDoc!.get().then((value) {
                    setState((){goal = value[FirebaseService().dbGoalMap[curField]!];});
                  });
                });
              }),
            ),
            SizedBox(height:30),
            SizedBox(
              width: 400,
              height: 275,
              child: (points == null) ? SizedBox.shrink() : LineChart(
                swapAnimationDuration: Duration(milliseconds: 150),
                swapAnimationCurve: Curves.linear,
                LineChartData(

                  minX: xmin.toDouble(),
                  maxX: xmax.toDouble(),
                  minY: ymin.toDouble(),
                  maxY: ymax.toDouble(),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: (goal > ymin && goal < ymax) ? [
                      HorizontalLine(
                        y: goal.toDouble(),
                        color: Colors.red,
                      )
                    ] : []
                  ),
                  gridData: FlGridData(
                    drawHorizontalLine: false,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        axisNameWidget: Text('Date'),
                        axisNameSize: 22,
                        sideTitles:SideTitles(
                          showTitles: true,
                          getTitlesWidget: getDateAxisTickVals,
                          interval: 1
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: Text(FirebaseService().dbTitleMap[curField]!),
                        axisNameSize: 22,
                        sideTitles:SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: getUnitAxisTickVals,
                          // interval: (ymax-ymin).toDouble()
                        ),
                      ),
                      rightTitles: AxisTitles(
                      ),
                      topTitles: AxisTitles(
                      )
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points,
                      isCurved: true,
                      // dotData: FlDotData(
                      //   show: false,
                      // ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
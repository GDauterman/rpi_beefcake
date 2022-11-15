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

  static const List<int> possibleIntervals = [1, 2, 3, 5, 10, 25, 50, 100, 200, 250, 500, 1000];

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
  final SingleValueDropDownController ddController = SingleValueDropDownController();
  DBFields curField = DBFields.caloriesN;

  void getGoal(num ngoal) {
    setState(() {
      goal = ngoal;
    });
  }

  void queryForNewField() {
    FirebaseService().getRawPlotPoints(curField, getPoints, 10);
    FirebaseService().userDoc!.get().then((value) {
      setState((){goal = value[FirebaseService().dbGoalMap[curField]!];});
    });
    trendm = FirebaseService().trendsDoc!.get(FirebaseService().dbTrendMap[curField]![0]);
    trendb = FirebaseService().trendsDoc!.get(FirebaseService().dbTrendMap[curField]![1]);
  }

  List<num> getIntervalRate(num min, num max, int intervalCount) {
    int? minDiff;
    int minVal = 0;
    for(int i = 0; i < possibleIntervals.length; i++) {
      int curDiff = (((max-min)/possibleIntervals[i]).floor()-intervalCount).abs();
      if(minDiff == null || curDiff < minDiff){
        minDiff = curDiff;
        minVal = i;
      }
    }
    num finalInterval = possibleIntervals[minVal];
    num newMin = (min/finalInterval).floor()*finalInterval;
    num newMax = (max/finalInterval).ceil()*finalInterval;

    return [newMin, newMax, finalInterval];
  }

  void getPoints(List<dynamic> newPoints) {
    setState(() {
      xmin = newPoints[0] as num;
      xmax = newPoints[1] as num;
      ymin = newPoints[2] as num;
      ymax = newPoints[3] as num;

      trendpoints = [
        FlSpot(xmin as double, trendm*xmin+trendb as double),
        FlSpot(xmax as double, trendm*xmax+trendb as double),
      ];

      ymin = min(min(ymin, trendpoints![0].y), trendpoints![1].y);
      ymax = max(max(ymax, trendpoints![0].y), trendpoints![1].y);

      points = newPoints[4].cast<FlSpot>();
    });
  }

  static Widget getUnitAxisTickVals(double value, TitleMeta meta) {
    return SideTitleWidget(
      // angle: -pi/2,
      axisSide: meta.axisSide,
      child: Text(
        value.toInt().toString()
        //style: COLOR: text style for individual axis ticks
      ),
    );
  }

  static Widget getDateAxisTickVals(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toString().substring(4,6) + "/" + value.toString().substring(6,8),
        //style: COLOR: text style for individual axis ticks
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
        queryForNewField();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(points != null && points!.length != 0) {
      List<num> yres = getIntervalRate(ymin, ymax, 6);
      List<num> xres = getIntervalRate(xmin, xmax, 6);
      xmin = xres[0];
      xmax = xres[1];
      xinterval = xres[2];
      ymin = yres[0];
      ymax = yres[1];
      yinterval = yres[2];
    }
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
                  queryForNewField();
                });
              }),
            ),
            SizedBox(height:30),
            SizedBox(
              width: 350,
              height: 275,
              child: (points == null || points!.length == 0) ?
                  Center(
                    child: Text('No logged data in the last 7 days')
                  )
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
                      color: Colors.black // COLOR: colors of each individual border (also width)
                    )
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: (goal > ymin && goal < ymax) ? [
                      HorizontalLine(
                        y: goal.toDouble(),
                        color: Colors.red, //COLOR: color of goal line
                      )
                    ] : []
                  ),
                  gridData: FlGridData(
                    drawHorizontalLine: false,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        axisNameWidget: Text('Date'), // COLORS: Text widget for x axis title
                        axisNameSize: 22,
                        sideTitles:SideTitles(
                          showTitles: true,
                          getTitlesWidget: getDateAxisTickVals,
                          interval: xinterval.toDouble(),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: Text(FirebaseService().dbTitleMap[curField]!), // COLORS: Text widget for x axis title
                        axisNameSize: 22,
                        sideTitles:SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: getUnitAxisTickVals,
                          interval: yinterval.toDouble(),
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
                    LineChartBarData(
                      spots: trendpoints,
                      color: Colors.greenAccent, //COLOR: color of trend line
                      dotData: FlDotData(
                        show: false,
                      ),
                    )
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
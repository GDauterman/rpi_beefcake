// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendsPage extends StatelessWidget {
  const TrendsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LineChart(
          LineChartData(

          ),
          swapAnimationDuration: Duration(milliseconds: 150),
          swapAnimationCurve: Curves.linear,
        ),
      ),
    );
  }
}

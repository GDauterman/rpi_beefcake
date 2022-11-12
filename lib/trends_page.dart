// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late final List<DropDownValueModel> dbDropDownList;
  final SingleValueDropDownController ddController = SingleValueDropDownController();
  DBFields curField = DBFields.caloriesN;

  void getPoints(List<FlSpot> newPoints) {
    setState(() {points = newPoints;});
  }

  static Widget custGetTitle(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue.substring(5),
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
                  if(val is! String) {
                    curField = val.value;
                  }
                  points = null;

                  FirebaseService().getRawPlotPoints(curField, getPoints, 7);
                });
              }),
            ),
            SizedBox(height:30),
            SizedBox(
              width: 300,
              height: 225,
              child: (points == null) ? SizedBox.shrink() : LineChart(
                swapAnimationDuration: Duration(milliseconds: 150),
                swapAnimationCurve: Curves.linear,
                LineChartData(
                  gridData: FlGridData(
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text('Date'),
                      axisNameSize: 5,
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(FirebaseService().dbTitleMap[curField]!),
                      axisNameSize: 5,
                    ),
                    rightTitles: AxisTitles(
                      sideTitles:SideTitles(
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles:SideTitles(
                          getTitlesWidget: custGetTitle,
                          interval: 7
                      ),
                    )
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points,
                      isCurved: false,
                      // dotData: FlDotData(
                      //   show: false,
                      // ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                        '${FirebaseService().dbTitleMap[curField]} History',
                      style: TextStyle(
                        fontSize: 30
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 8), child: DataRow(curField, 0)),
                  Padding(padding: EdgeInsets.only(top: 8), child: DataRow(curField, 1)),
                  Padding(padding: EdgeInsets.only(top: 8), child: DataRow(curField, 2)),
                  ]
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}

class DataRow extends StatefulWidget {
  final DBFields field;
  final num index;
  DataRow(this.field, this.index, {Key? key}) : super(key: key);

  State<DataRow> createState() => _DataRow();
}

class _DataRow extends State<DataRow> {
  late String title;
  late String units;

  @override
  void initState() {
    super.initState();
    final curDocStream = FirebaseService().dbColMap[widget.field]!.orderBy("time_logged", descending: true);

  }

  @override
  Widget build(BuildContext context) {
    title = FirebaseService().dbTitleMap[widget.field]!;
    units = FirebaseService().dbUnitMap[widget.field]!;

    return StreamBuilder(

        builder: (context, snapshot) {
          String val = '--';
          if(snapshot.hasData) {
             //val = snapshot.data!.get(FirebaseService().dbGoalMap[widget.field]!).toString();
          }
          return GestureDetector(
            // onTap: (() {
            //   Navigator.push(context, CustomPopupRoute(builder: (context) => FieldModificationPopup(widget.field)));
            // }),
            child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                          color: Colors.indigo,
                          width: 2.5,
                        ),
                        bottom: BorderSide(
                          color: Colors.indigo,
                          width: 2.5,
                        )
                    )
                ),
                child: SizedBox(
                  height: 100,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                      fontSize: 25
                                  ),
                                ),
                                Text(
                                    units,
                                    style: TextStyle(
                                        fontSize: 20
                                    )
                                )
                              ]
                          ),
                          Text(
                            val,
                            style: TextStyle(
                                fontSize: 50
                            ),
                          )
                        ]
                    ),
                  ),
                )
            ),
          );
        }
    );
  }

}
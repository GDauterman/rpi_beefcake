// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/style_lib.dart';
import 'firestore.dart';

class FitnessPage extends StatefulWidget {
  FirebaseService db;
  FitnessPage(this.db, {Key? key}) : super(key: key);

  @override
  State<FitnessPage> createState() => _FitnessPage();
}

class _FitnessPage extends State<FitnessPage> {
  String curExercise = 'Bench Press';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 25, 0, 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: bc_style().backgroundcolor,
                        border: Border.all(width: 5, color: bc_style().accent2color),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        child: Text(curExercise,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Proxima Nova',
                            fontSize: 30,
                            color: bc_style().textcolor,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: (() {
                        setState(() {curExercise = '';});
                      }),
                      icon: Icon(Icons.dangerous_rounded, color: bc_style().errorcolor),
                    ),
                  ],
                ),
              ),
            ]
          )
        )
      )
    );
  }

}

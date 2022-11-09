// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/firestore.dart';
import 'package:rpi_beefcake/widget_library.dart';

enum healthSubPages { options, sleep, nutrition, hydration }

class HealthPage extends StatefulWidget {
  final FirebaseService db;
  healthSubPages curPage = healthSubPages.options;

  HealthPage(this.db, {Key? key}) : super(key: key);

  State<HealthPage> createState() => _HealthPage();
}

class _HealthPage extends State<HealthPage> {
  void backCallback() {
    setState(() { widget.curPage = healthSubPages.options; });
  }

  @override
  Widget build(BuildContext context) {
    switch(widget.curPage) {
      case healthSubPages.options:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: (() {
                    setState(() {widget.curPage = healthSubPages.nutrition;});
                  }),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'Log Nutrition',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: (() {
                    setState(() {widget.curPage = healthSubPages.sleep;});
                  }),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'Log Sleep',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: (() {
                    setState(() {widget.curPage = healthSubPages.hydration;});
                  }),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'Log Hydration',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
              ),
            ],
          )
        );
      case healthSubPages.sleep:
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 40,
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    onPressed: backCallback,
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    )
                  ),
                ),
              ),
              SleepPage(widget.db.addSleep)
            ]
          ),
        );
      case healthSubPages.hydration:
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 40,
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: backCallback,
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    )
                  ),
                ),
              ),
              HydrationPage(widget.db.addHydration)
            ]
          )
        );
      case healthSubPages.nutrition:
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 40,
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: backCallback,
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    )
                  ),
                ),
              ),
              NutritionPage(widget.db.addNutrition)
            ]
          ),
        );
    }
  }
}

class HydrationPage extends StatelessWidget {
  serviceCallback logFunc;
  HydrationPage(this.logFunc, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    List<FieldOptions> sleepOptions = [
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
              FieldWithEnter(fieldOptions: sleepOptions, dataEntry: logFunc),
            ]
        ),
      ),
    );
  }
}

class NutritionPage extends StatelessWidget {
  serviceCallback logFunc;
  NutritionPage(this.logFunc, {Key? key}) : super(key: key);

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
              FieldWithEnter(fieldOptions: sleepOptions, dataEntry: logFunc),
            ]
        ),
      ),
    );
  }
}

class SleepPage extends StatelessWidget {
  serviceCallback logFunc;
  SleepPage(this.logFunc, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
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
              padding: EdgeInsets.only(top:20),
              child: Text(
                'Sleep Entry',
                style: TextStyle(
                  fontSize: 35
                ),
              ),
            ),
            FieldWithEnter(fieldOptions: sleepOptions, dataEntry: logFunc),
          ]
        ),
      ),
    );
  }
}

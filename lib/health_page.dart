// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/firestore.dart';
import 'package:rpi_beefcake/widget_library.dart';

// stateful due to errortext being required for this logging popup
/// Stateful Widget that represents the page for logging a body measuremnent
///
/// State depends on changing values in fields
class MeasurementPage extends StatefulWidget {
  MeasurementPage({Key? key}) : super(key: key);

  @override
  State<MeasurementPage> createState() => _MeasurementPage();
}

/// Underlying state implementation of MeasurementPage
class _MeasurementPage extends State<MeasurementPage> {
  // Options and widgets for all inputs for this page
  late final FieldOptions _weightOptions;
  late final FieldOptions _waistOptions;
  late final FieldOptions _bicepOptions;
  late final CustTextInput _weightInput;
  late final CustTextInput _waistInput;
  late final CustTextInput _bicepInput;

  // string that should be shown beneath submit in the case of user error
  String _errorText = '';

  @override
  initState() {
    _weightOptions = FieldOptions(
      hint: 'Current Weight (lbs)',
      invalidText: 'Enter a number',
      keyboard: TextInputType.number,
      regString: r'^0*\d*(\.\d+)?$',
    );
    _waistOptions = FieldOptions(
      hint: 'Waist Circumference (in.)',
      invalidText: 'Enter a number',
      keyboard: TextInputType.number,
      regString: r'^0*\d*(\.\d+)?$',
    );
    _bicepOptions = FieldOptions(
      hint: 'Bicep Circumference (in.)',
      invalidText: 'Enter a number',
      keyboard: TextInputType.number,
      regString: r'^0*\d*(\.\d+)?$',
    );
    _weightInput = CustTextInput(options: _weightOptions);
    _waistInput = CustTextInput(options: _waistOptions);
    _bicepInput = CustTextInput(options: _bicepOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
      // Sleep Container
      child: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Body Measurement Entry',
              style: TextStyle(fontSize: 35),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 7),
            child: Text(
              'Enter at least 1 value',
              style: TextStyle(fontSize: 15),
            ),
          ),
          _weightInput,
          _waistInput,
          _bicepInput,
          ElevatedButton(
              // Checks for validity of log attempt, shows error if not valid,
              // logs and clears values if valid
              onPressed: (() {
                if (_weightInput.child.isEmpty() &&
                    _waistInput.child.isEmpty() &&
                    _bicepInput.child.isEmpty()) {
                  setState(() {
                    _errorText = 'Enter at least one metric before submitting';
                  });
                } else if (_weightInput.child.isValid() &&
                    _waistInput.child.isValid() &&
                    _bicepInput.child.isValid()) {
                  setState(() {
                    _errorText = '';
                  });
                  FirebaseService().addMeasurement([
                    _weightInput.child.getVal(),
                    _waistInput.child.getVal(),
                    _bicepInput.child.getVal()
                  ]);
                  _weightInput.child.clear();
                  _waistInput.child.clear();
                  _bicepInput.child.clear();
                }
              }),
              child: Text('Submit')),
          Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                _errorText,
                style: TextStyle(color: Theme.of(context).errorColor),
              ))
        ]),
      ),
    );
  }
}

/// Stateless Widget that represents the page for logging hydration
class HydrationPage extends StatelessWidget {
  HydrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Hydration Entry',
              style: TextStyle(fontSize: 35),
            ),
          ),
          FieldWithEnter(
              fieldOptions: sleepOptions,
              dataEntry: FirebaseService().addHydration),
        ]),
      ),
    );
  }
}

/// Stateless Widget that represents the page for logging nutrition
class NutritionPage extends StatelessWidget {
  NutritionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Nutrition Entry',
              style: TextStyle(fontSize: 35),
            ),
          ),
          FieldWithEnter(
              fieldOptions: sleepOptions,
              dataEntry: FirebaseService().addNutrition),
        ]),
      ),
    );
  }
}

/// Stateless Widget that represents the page for logging sleep
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
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Sleep Entry',
              style: TextStyle(fontSize: 35),
            ),
          ),
          FieldWithEnter(
              fieldOptions: sleepOptions,
              dataEntry: FirebaseService().addSleep),
        ]),
      ),
    );
  }
}

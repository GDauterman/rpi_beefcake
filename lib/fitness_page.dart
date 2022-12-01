// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/style_lib.dart';
import 'package:rpi_beefcake/widget_library.dart';
import 'firestore.dart';

// ToDo: replace with database call
/// Represents all possible exercise fields
List<String> exercisesList = <String>['Bench Press', 'Squat', 'Deadlift'];

/// A StatefulWidget representing the exercise logging page of our app
///
/// State is based on entered values and change in count of rows
class FitnessPage extends StatefulWidget {
  FitnessPage({Key? key}) : super(key: key);

  @override
  State<FitnessPage> createState() => _FitnessPage();
}

/// Underlying state class for FitnessPage
class _FitnessPage extends State<FitnessPage> {
  /// Text that should be shown beneath submit button in case of user error
  String errorText = '';

  /// deletes the exercise log row at index [i]
  void deleteRow(UniqueKey uk) {
    if (_rows.isEmpty) return;
    setState(() {
      _rows.removeWhere((item) => item.key == uk);
      for(int i = 0; i < _rows.length; i++) {
        _rows[i].child.decrementIndex();
      }
    });
  }

  /// Adds new row to end of exercise log list
  void addRow() {
    setState(() {
      _rows.add(FitnessRow(getIndex, deleteRow, UniqueKey()));
    });
  }

  /// Clears values in all exercise logging rows
  void clearRows() {
    setState(() {
      for (int i = 0; i < _rows.length; i++) {
        _rows[i].child.clear();
      }
    });
  }

  int getIndex(UniqueKey uk) {
    return _rows.indexWhere((item) => item.key == uk) + 1;
  }

  /// Whether all exercise row values are valid according to their regexp
  bool rowsValid() {
    if(_rows.isEmpty) {
      return false;
    }
    for (int i = 0; i < _rows.length; i++) {
      if (!_rows[i].child.areValid()) {
        return false;
      }
    }
    return true;
  }

  /// Logs the values entered in all exercise logging rows
  void logRows() {
    setState(() {
      List<dynamic> data = [];

      data.add(_exerciseDropdown.child.getSelection().toString());
      data.add('notes');
      List<dynamic> reps = [];
      List<dynamic> weight = [];
      data.add(reps);
      data.add(weight);
      for (int i = 0; i < _rows.length; i++) {
        data[2].add(num.parse(_rows[i].child.getFields()?[1]));
        data[3].add(num.parse(_rows[i].child.getFields()?[0]));
      }
      FirebaseService().addWorkout(data);
      clearRows();
    });
  }

  /// Dropdown widget for searchable dropdown of exercise options
  final CustDropdown _exerciseDropdown = CustDropdown(exercisesList);

  /// List of exercise row widgets
  List<FitnessRow> _rows = [];

  @override
  initState() {
    for (int i = 0; i < 3; i++) {
      addRow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 10),
            child: _exerciseDropdown,
          ),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: _rows),
          Padding(
              padding: EdgeInsets.zero,
              child: ElevatedButton(onPressed: addRow, child: Text('Add Set'))),
          Padding(
              padding: EdgeInsets.only(top: 10),
              child: ElevatedButton(
                  onPressed: (() {
                    if (rowsValid()) {
                      errorText = '';
                      logRows();
                    } else {
                      setState(() {
                        errorText = 'Please enter something for all fields';
                      });
                    }
                  }),
                  child: Text('Log Set'))),
          Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                errorText,
                style: TextStyle(color: Theme.of(context).errorColor),
              )),
        ]))));
  }
}

/// A Stateful Widget representing a row to log a single set of an exercise
///
/// State is dependent on changes to child fields
class FitnessRow extends StatefulWidget {
  /// Callback when this widget is deleted
  ValueSetter<UniqueKey> deleteRow;

  /// Callback to get index of this widget in list
  int Function(UniqueKey) getIndex;

  /// Accessor to be able to call member functions of the underlying State widget
  late FitnessRowState child;

  /// Unique key of this specific row
  @override
  UniqueKey key;

  FitnessRow(this.getIndex, this.deleteRow, this.key) : super(key: key);

  @override
  State<FitnessRow> createState() {
    child = FitnessRowState();
    return child;
  }

  @override
  State<FitnessRow> state() {
    return child;
  }

}

/// Underlying state class for FitnessRow
class FitnessRowState extends State<FitnessRow> {
  late final FieldOptions _weightOptions;
  late final FieldOptions _repOptions;
  late CustTextInput _weightInput;
  late CustTextInput _repInput;

  /// Returns list of both values in the fields of this row
  ///
  /// Returns an empty list if they are not both valid
  List<dynamic>? getFields() {
    if (_weightInput.child.isValid() && _repInput.child.isValid()) {
      return [_weightInput.child.getVal(), _repInput.child.getVal()];
    }
    List<dynamic> empty = [];
    return (empty);
  }

  /// Whether all fields in this row are valid
  bool areValid() {
    return _weightInput.child.isValid() && _repInput.child.isValid();
  }

  /// decrement the index of this row
  void decrementIndex() {
    setState((){});
  }

  /// Clears all fields in this row
  void clear() {
    _weightInput.child.clear();
    _repInput.child.clear();
  }

  @override
  initState() {
    _weightOptions = FieldOptions(
      hint: 'Weight (lbs)',
      regString: r'^0*\d+(\.\d+)?$',
      keyboard: TextInputType.number,
      boxwidth: 100,
      boxheight: 50,
      showValidSymbol: false,
    );

    _repOptions = FieldOptions(
      hint: 'Reps',
      regString: r'\d{1,3}',
      keyboard: TextInputType.number,
      boxwidth: 50,
      boxheight: 50,
      showValidSymbol: false,
    );

    _weightInput = CustTextInput(options: _weightOptions);
    _repInput = CustTextInput(options: _repOptions);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Text(
              widget.getIndex(widget.key).toString(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.5),
            child: _weightInput,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.5),
            child: _repInput,
          ),
          Padding(
              padding: EdgeInsets.only(left: 10),
              child: IconButton(
                icon: Icon(Icons.backspace_outlined),
                color: Theme.of(context).colorScheme.primary,
                iconSize: 28,
                onPressed: (() {
                  setState(() { widget.deleteRow(widget.key); });
                }),
              ))
        ]));
  }

  @override
  dispose() {
    super.dispose();
  }
}

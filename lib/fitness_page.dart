// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/style_lib.dart';
import 'package:rpi_beefcake/widget_library.dart';
import 'firestore.dart';

List<String> exercisesList = <String>['Bench Press', 'Squat', 'Deadlift', 'Glute Spread'];

class FitnessPage extends StatefulWidget {
  FitnessPage({Key? key}) : super(key: key);

  @override
  State<FitnessPage> createState() => _FitnessPage();
}

class _FitnessPage extends State<FitnessPage> {

  void deleteIndex(int i) {
    i -= 1;
    if(rows.isEmpty || i < 0 || i >= rows.length) return;
    setState(() {
      rows.removeAt(i);
      for (; i < rows.length; i++) {
        rows[i].child.decrementIndex();
      }
    });
  }
  void addRow() {
    setState(() {
      rows.add(FitnessRow(deleteIndex, rows.length + 1));
    });
  }
  void clearRows() {
    setState(() {
      for (int i = 0; i < rows.length; i++) {
        rows[i].child.clear();
      }
    });
  }
  void logRows() {
    setState(() {
      List<dynamic> data = [];

      data.add(exerciseDropdown.child.getSelection().toString());
      data.add('notes');
      List<dynamic> reps = [];
      List<dynamic> weight = [];
      data.add(reps);
      data.add(weight);
      for(int i =0; i<rows.length;i++) {
        data[2].add(num.parse(rows[i].child.getFields()?[1]));
        data[3].add(num.parse(rows[i].child.getFields()?[0]));
      }
      FirebaseService().addWorkout(data);
      clearRows();
    });
  }
  final CustDropdown exerciseDropdown = CustDropdown(exercisesList);
  List<FitnessRow> rows = [];

  @override
  initState() {
    for(int i = 1; i <= 3; i++) {
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
                child: exerciseDropdown,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: rows
              ),
              Padding(
                padding: EdgeInsets.zero,
                child: ElevatedButton(
                  onPressed: addRow,
                  child: Text('Add Set')
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: logRows,
                  child: Text('Log Set')
                )
              ),
            ]
          )
        )
      )
    );
  }

}

class FitnessRow extends StatefulWidget {
  ValueSetter<int> deleteRow;
  late _FitnessRow child;
  int initIndex;
  FitnessRow(this.deleteRow, this.initIndex, {Key? key}) : super(key: key);

  @override
  State<FitnessRow> createState() {
    child = _FitnessRow();
    return child;
  }
}

class _FitnessRow extends State<FitnessRow> {

  late CustTextInput weightInput;
  late CustTextInput repInput;
  late int index;

  List<dynamic>? getFields() {
    if(weightInput.child.isValid() && repInput.child.isValid()) {
      return [weightInput.child.getVal(), repInput.child.getVal()];
    }
    List<dynamic> empty = [];
    return(empty);
  }

  void clear() {
    weightInput.child.clear();
    repInput.child.clear();
  }

  void decrementIndex() {
    setState(() {index--;});
  }

  @override
  initState() {
    FieldOptions weightOptions = FieldOptions(
      hint: 'Weight (lbs)',
      regString: r'^0*\d+(\.\d+)?$',
      keyboard: TextInputType.number,
      boxwidth: 100,
      boxheight: 50,
      showValidSymbol: false,
    );
    weightInput = CustTextInput(options: weightOptions);

    FieldOptions repOptions = FieldOptions(
      hint: 'Rps',
      regString: r'\d{1,3}',
      keyboard: TextInputType.number,
      boxwidth: 50,
      boxheight: 50,
      showValidSymbol: false,
    );
    repInput = CustTextInput(options: repOptions);

    index = widget.initIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Text(
              index.toString(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.5),
            child: weightInput,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.5),
            child: repInput,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: IconButton(
              icon: Icon(Icons.backspace_outlined),
              color: Theme.of(context).colorScheme.primary,
              iconSize: 28,
              onPressed: (() {widget.deleteRow(index);}),
            )
          )
        ]
      )
    );
  }
}
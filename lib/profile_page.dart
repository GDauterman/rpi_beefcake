import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/widget_library.dart';

import 'firestore.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final Stream<DocumentSnapshot> userDocStream = FirebaseService().userDoc!.snapshots();
  final List<DBFields> goalFields = [DBFields.caloriesN, DBFields.carbsN, DBFields.fatN, DBFields.proteinN, DBFields.durationS, DBFields.quantityH];

  @override
  Widget build(BuildContext context){
    return StreamBuilder(
      stream: userDocStream,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Set Goals',
                  style: TextStyle(
                      fontSize: 35
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 8), child: GoalRow(userDocStream, DBFields.caloriesN)),
              Padding(padding: EdgeInsets.only(top: 8), child: GoalRow(userDocStream, DBFields.proteinN)),
              Padding(padding: EdgeInsets.only(top: 8), child: GoalRow(userDocStream, DBFields.fatN)),
              Padding(padding: EdgeInsets.only(top: 8), child: GoalRow(userDocStream, DBFields.carbsN)),
              Padding(padding: EdgeInsets.only(top: 8), child: GoalRow(userDocStream, DBFields.durationS)),
              Padding(padding: EdgeInsets.only(top: 8), child: GoalRow(userDocStream, DBFields.quantityH)),
            ]
          ),
        );
      }
    );
  }
}

class GoalRow extends StatefulWidget {
  final Stream<DocumentSnapshot> userDocSnapshot;
  final DBFields field;
  GoalRow(this.userDocSnapshot, this.field, {Key? key}) : super(key: key);

  State<GoalRow> createState() => _GoalRow();
}

class _GoalRow extends State<GoalRow> {
  late String title;
  late String units;

  @override
  void initState() {
    super.initState();
    title = FirebaseService().dbTitleMap[widget.field]!;
    units = FirebaseService().dbUnitMap[widget.field]!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.userDocSnapshot,
      builder: (context, snapshot) {
        String val = '--';
        if(snapshot.hasData) {
          val = snapshot.data!.get(FirebaseService().dbGoalMap[widget.field]!).toString();
        }
        return GestureDetector(
          onTap: (() {
            Navigator.push(context, CustomPopupRoute(builder: (context) => FieldModificationPopup(widget.field)));
          }),
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
                            fontSize: 35
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

class FieldModificationPopup extends StatefulWidget {
  final DBFields field;
  FieldModificationPopup(this.field, {Key? key}) : super(key: key);

  @override
  State<FieldModificationPopup> createState() => _FieldModificationPopup();
}

class _FieldModificationPopup extends State<FieldModificationPopup> {

  late final CustTextInput textInput;

  @override
  initState() {
    super.initState();
    FieldOptions popupOptions = FieldOptions(
      hint: FirebaseService().dbTitleMap[widget.field],
      invalidText: 'Enter a number',
      regString: r'\d+',
      keyboard: TextInputType.number,
      showValidSymbol: false);
    textInput = CustTextInput(options: popupOptions);

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 300),
      child: Material(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(width: 5, color: Colors.white),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                textInput,
                ButtonTheme(
                  minWidth: 50,
                  child: ElevatedButton(
                    onPressed: (() {
                      FirebaseService().updateGoal(widget.field, num.parse(textInput.child.getVal()));
                      Navigator.pop(context);
                    }),
                    child: SizedBox(
                      child: Text('Submit'),
                    ),
                  )
                )
              ],
            ),
          ),
    )));
  }

}
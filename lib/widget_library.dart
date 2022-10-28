import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/firestore.dart';

class FieldOptions {
  String validationRegex;
  String hint;
  String invalidText;
  TextInputType keyboard;
  FieldOptions({this.hint = '', this.invalidText = '', this.validationRegex = r'.*', this.keyboard = TextInputType.none});
}

class FieldWithEnter extends StatefulWidget {
  final FirebaseService db;
  final String titleText;
  final List<FieldOptions> fieldOptions;
  final void Function(List<dynamic>) dataEntry;
  const FieldWithEnter({Key? key, required this.db, required this.titleText, required this.fieldOptions, required this.dataEntry }) : super(key: key);

  @override
  _FieldWithEnter createState() {
    return _FieldWithEnter();
  }
}

class _FieldWithEnter extends State<FieldWithEnter> {
  List<TextEditingController> controllers = List<TextEditingController>.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    List<Widget> fieldList = List<Widget>.empty(growable: true);
    for(int i = 0; i < widget.fieldOptions.length; i++) {
      controllers.add(TextEditingController());
      fieldList.add(buildTextInputRow(controllers[i], widget.fieldOptions[i]));
    }
    return Container(
      padding: const EdgeInsets.all(30.0),
      color: Colors.white,
      child: Center(
        child: Column(children: [
        const Padding(padding: EdgeInsets.only(top: 140.0)),
        Text(
          widget.titleText,
          style: const TextStyle(
            color: Color.fromARGB(255, 242, 160, 61), fontSize: 25.0),
        ),
        const Padding(padding: EdgeInsets.only(top: 20.0)),
        Column(
          children: fieldList,
        ),
        Form(
          child: ElevatedButton(
            onPressed: /*(_formKey.currentState == null) ? null :*/ () {
              List<dynamic> enteredData = List<dynamic>.empty(growable: true);
              for(int i = 0; i < widget.fieldOptions.length; i++) {
                print('accessing controllers');
                if(RegExp(widget.fieldOptions[i].validationRegex).hasMatch(controllers[i].text.toString())) {
                  enteredData.add(controllers[i].text);
                  controllers[i].clear();
                } else{
                  print('{$i} doesn\'t match');
                  return;
                }
              }
              widget.dataEntry(enteredData);
            },
            child: const Text('Submit')
          ),
        ),
      ])),
    );
  }

  Widget buildTextInputRow(TextEditingController textEditingController, FieldOptions options) {
    // return Text('baller');
    return Container(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: TextField(
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: options.hint,
          errorText: (() {
            final text = textEditingController.value.text;
            RegExp matchReg = RegExp(options.validationRegex);
            if (matchReg.hasMatch(text)) {
              return null;
            }
            return options.invalidText;
          } ()),
        ),
        keyboardType: options.keyboard,
        onChanged: (String str) {
          (() {

          });
        }
      )
    );
  }
}



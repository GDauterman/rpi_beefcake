import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/firestore.dart';

class FieldWithEnter extends StatefulWidget {
  final FirebaseService db;
  final String titleText;
  final int fieldsCount;
  final List<String> boxText;
  final List<String> regex;
  final void Function(List<dynamic>) dataEntry;
  const FieldWithEnter({Key? key, required this.db, required this.titleText, required this.fieldsCount, required this.boxText, required this.regex, required this.dataEntry }) : super(key: key);

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
    for(int i = 0; i < widget.fieldsCount; i++) {
      controllers.add(TextEditingController());
      print('accessing first controllers');
      fieldList.add(buildTextInputRow(controllers[i], hintText: widget.boxText[i]));
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
              for(int i = 0; i < widget.fieldsCount; i++) {
                print('accessing controllers');
                if(controllers[i].text.toString().contains(widget.regex[i])) {
                  enteredData.add(controllers[i].text);
                } else{
                  print('{$i} doesnt match');
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

  Widget buildTextInputRow(TextEditingController textEditingController, {String hintText = ''}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: TextField(
          controller: textEditingController,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: (() {
              final text = textEditingController.value.text;
              // ToDo: allow passing in validators
              return null;
            } ()),
          ),
          keyboardType: TextInputType.number,
          onChanged: (String str) {
            (() {

            });
          }
        )
      ),
    );
  }
}



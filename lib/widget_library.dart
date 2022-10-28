import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/firestore.dart';

class FieldOptions {
  late RegExp validationRegex;
  String hint;
  String invalidText;
  TextInputType keyboard;
  FieldOptions(this.hint, this.invalidText, this.keyboard, String regString) {
    validationRegex = RegExp(regString);
  }
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
  List<TextEditingController> controllers = List<TextEditingController>.empty(
      growable: true);


  @override
  Widget build(BuildContext context) {
    List<TextInputRow> fieldList = List<TextInputRow>.empty(growable: true);
    for (int i = 0; i < widget.fieldOptions.length; i++) {
      controllers.add(TextEditingController());
      fieldList.add(TextInputRow(textEditingController: controllers[i], options: widget.fieldOptions[i]));
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
                    List<dynamic> enteredData = List<dynamic>.empty(
                        growable: true);
                    for (int i = 0; i < widget.fieldOptions.length; i++) {
                      print('accessing controllers');
                      String contText = controllers[i].text;
                      if (widget.fieldOptions[i].validationRegex.hasMatch(contText)) {
                        enteredData.add(contText);
                      } else {
                        print('{$i} doesn\'t match');
                        return;
                      }
                    }
                    for (int i = 0; i < widget.fieldOptions.length; i++) {
                      controllers[i].clear();
                    }
                    widget.dataEntry(enteredData);
                  },
                  child: const Text('Submit')
              ),
            ),
          ])),
    );
  }
}

class TextInputRow extends StatefulWidget {
  final TextEditingController textEditingController;
  final FieldOptions options;

  const TextInputRow(
      {Key? key, required this.textEditingController, required this.options})
      : super(key: key);

  @override
  _TextInputRow createState() {
    return _TextInputRow();
  }
}

class _TextInputRow extends State<TextInputRow> {

  bool _isValid = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Text('baller');
    return Container(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: TextField(
        controller: widget.textEditingController,
        decoration: InputDecoration(
          hintText: widget.options.hint,
          errorText: (() {
            return _isValid ? null : widget.options.invalidText;
          } ()),
        ),
        keyboardType: widget.options.keyboard,
        onChanged: (String str) {
          setState(() {
            _isValid = widget.options.validationRegex.hasMatch(str);
          });
          print("changed isvalid to " + _isValid.toString());
        }
      )
    );
  }
}



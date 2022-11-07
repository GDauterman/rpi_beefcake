import 'package:flutter/material.dart';
import 'package:rpi_beefcake/firestore.dart';
import 'package:rpi_beefcake/style_lib.dart';


class FieldOptions {
  late RegExp validationRegex;
  String? hint;
  String? invalidText;
  bool showValidSymbol;
  TextInputType keyboard;
  bool obscureText;
  Icon? prefixIcon;
  double? boxheight;
  double? boxwidth;
  FieldOptions({this.boxheight, this.showValidSymbol = true, this.boxwidth, this.hint, this.invalidText, this.keyboard = TextInputType.text, String regString = '.*', IconData? icon, this.obscureText = false}) {
    validationRegex = RegExp(regString);
    if(icon != null) {
      prefixIcon = Icon(icon, color: bc_style().textcolor);
    } else {
      prefixIcon = null;
    }
  }
}

class FieldWithEnter extends StatefulWidget {
  final List<FieldOptions> fieldOptions;
  final serviceCallback dataEntry;
  final String submitText;
  const FieldWithEnter({Key? key, required this.fieldOptions, required this.dataEntry, this.submitText = 'Submit' }) : super(key: key);

  @override
  _FieldWithEnter createState() {
    return _FieldWithEnter();
  }
}

class _FieldWithEnter extends State<FieldWithEnter> {

  @override
  Widget build(BuildContext context) {
    List<CustTextInput> fieldList = List<CustTextInput>.empty(growable: true);
    for (int i = 0; i < widget.fieldOptions.length; i++) {
      fieldList.add(CustTextInput(options: widget.fieldOptions[i]));
    }
    return Container(
      padding: const EdgeInsets.all(30.0),
      color: bc_style().backgroundcolor,
      child: Center(
          child: Column(children: [
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
                      String contText = fieldList[i].child.getVal();
                      if (widget.fieldOptions[i].validationRegex.hasMatch(contText)) {
                        enteredData.add(contText);
                      } else {
                        print('{$i} doesn\'t match');
                        return;
                      }
                    }
                    for (int i = 0; i < widget.fieldOptions.length; i++) {
                      fieldList[i].child.clear();
                    }
                    widget.dataEntry(enteredData);
                  },
                  child: Text(widget.submitText)
              ),
            ),
          ])),
    );
  }
}

class CustTextInput extends StatefulWidget {
  final FieldOptions options;
  late _CustTextInput child;

  CustTextInput(
      {Key? key, required this.options})
      : super(key: key);

  @override
  _CustTextInput createState() {
    child = _CustTextInput();
    return child;
  }
}

class _CustTextInput extends State<CustTextInput> {

  TextEditingController controller = TextEditingController();
  bool _isValid = true;
  @override
  void initState() {
    super.initState();
  }

  bool isValid() {
    return _isValid;
  }

  void clear() {
    setState(() {controller.clear();});
  }

//TODO: make nullable and return null if not valid (should be on this func)
  String getVal() {
    return controller.text.toString();
  }

  @override
  Widget build(BuildContext context) {
    // return Text('baller');
    TextField tf = TextField(
      controller: controller,
      obscureText: widget.options.obscureText,
      keyboardType: widget.options.keyboard,
      decoration: InputDecoration(
        hintText: widget.options.hint,
        errorText: _isValid ? null : widget.options.invalidText,
        border: InputBorder.none,
        prefixIcon: widget.options.prefixIcon,
      ),
      onChanged: ((String str) {
        bool valid = widget.options.validationRegex.hasMatch(str);
        if (_isValid && !valid) {
          setState(() {_isValid = false;});
        } else if (!_isValid && valid) {
          setState(() {_isValid = true;});
        }
      }),
    );

    Container c;
    if(widget.options.boxheight == null || widget.options.boxwidth == null) {
      c = Container(
        child: Expanded(
          child: tf,
        ),
      );
    } else {
      c = Container(
        child: SizedBox(
          height: widget.options.boxheight,
          width: widget.options.boxwidth,
          child: tf,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Container(
        decoration: BoxDecoration(
          color: bc_style().backgroundcolor,
          border: Border.all(width: 5, color: bc_style().accent1color),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.only(bottom: 6, left: 5.0, right: 5.0, top: 6),
        child: Row(
          children: [
            c,
            widget.options.showValidSymbol ? Icon(_isValid ? Icons.check_circle : Icons.flag_circle_rounded, size: 28, color: _isValid ? bc_style().correctcolor : bc_style().errorcolor) : SizedBox.shrink(),
          ],
        )
      ),
    );
  }
}

class CustDropdown extends StatefulWidget {
  late _CustDropdown child;
  List<String> optionList;
  CustDropdown(this.optionList, {super.key});

  @override
  State<CustDropdown> createState() {
    child = _CustDropdown();
    return child;
  }
}

class _CustDropdown extends State<CustDropdown> {
  late String _curVal;

  String getSelection() {
    return _curVal;
  }

  @override
  initState() {
    _curVal = widget.optionList[0];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Container(
        decoration: BoxDecoration(
          color: bc_style().backgroundcolor,
          border: Border.all(width: 5, color: bc_style().accent1color),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
        child: DropdownButton<String>(
          value: _curVal,
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 16,
          style: TextStyle(color: bc_style().textcolor, fontSize: 24),
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              _curVal = value!;
            });
          },
          items: widget.optionList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
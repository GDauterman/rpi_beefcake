import 'package:flutter/material.dart';
import 'package:rpi_beefcake/firestore.dart';
import 'package:rpi_beefcake/style_lib.dart';
import 'dart:math' as math;

/// Function that takes in a string and retuns whether or not that value is valid
typedef bool ValidatorFunction(String str);

/// Class representation of a CustFieldInput's settings
class FieldOptions {
  /// regexp object to test validity of input
  late RegExp validationRegex;

  /// The validator function that can be used instead of regexp
  ValidatorFunction? validator;

  /// the hint to be shown on the field
  String? hint;

  /// the text to be shown when the field is invalid
  String? invalidText;

  /// the text to be shown after the field (mostly units)
  String? suffixText;

  /// max amount of characters to be shown
  int? maxlines;

  /// whether the input should show the validity flag
  bool showValidSymbol;

  /// which keyboard should be shown when the user has this input selected
  TextInputType keyboard;

  /// whether to obscure text in input
  bool obscureText;

  /// option to show an icon before the field
  Icon? prefixIcon;

  /// option for the size of the field
  ///
  /// This value not being set means the field will expand to whatever size it needs
  double? boxheight;
  double? boxwidth;
  FieldOptions(
      {this.validator,
      this.boxheight,
      this.maxlines,
      this.showValidSymbol = true,
      this.boxwidth,
      this.hint,
      this.invalidText,
      this.suffixText,
      this.keyboard = TextInputType.text,
      String regString = '.*',
      IconData? icon,
      this.obscureText = false}) {
    validationRegex = RegExp(regString);
    if (icon != null) {
      prefixIcon = Icon(icon, color: bc_style().textcolor);
    } else {
      prefixIcon = null;
    }
  }
}

/// A StatefulWidget representing a list of CustTextInputs with a submit button
class FieldWithEnter extends StatefulWidget {
  /// All fieldoptions to be used
  final List<FieldOptions> fieldOptions;

  /// A callback to be used to send data when submitting
  final ServiceCallback dataEntry;

  /// The string to be shown in the submit button
  final String submitText;

  const FieldWithEnter(
      {Key? key,
      required this.fieldOptions,
      required this.dataEntry,
      this.submitText = 'Submit'})
      : super(key: key);

  @override
  _FieldWithEnter createState() {
    return _FieldWithEnter();
  }
}

/// The underlying state input of FieldWithEnter
class _FieldWithEnter extends State<FieldWithEnter> {
  @override
  Widget build(BuildContext context) {
    List<CustTextInput> fieldList = List<CustTextInput>.empty(growable: true);
    for (int i = 0; i < widget.fieldOptions.length; i++) {
      fieldList.add(CustTextInput(options: widget.fieldOptions[i]));
    }
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: Center(
          child: Column(children: [
        Column(
          children: fieldList,
        ),
        Form(
          child: ElevatedButton(
              onPressed: /*(_formKey.currentState == null) ? null :*/ () {
                List<dynamic> enteredData = List<dynamic>.empty(growable: true);
                for (int i = 0; i < widget.fieldOptions.length; i++) {
                  print('accessing controllers');
                  String contText = fieldList[i].child.getVal();
                  if (widget.fieldOptions[i].validationRegex
                      .hasMatch(contText)) {
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
              child: Text(widget.submitText)),
        ),
      ])),
    );
  }
}

/// A StatefulWidget representing an inputfield with set [options]
class CustTextInput extends StatefulWidget {
  /// Options of this textinput
  final FieldOptions options;

  /// accessor to be able to access getters of this input
  late _CustTextInput child;

  CustTextInput({Key? key, required this.options}) : super(key: key);

  @override
  _CustTextInput createState() {
    child = _CustTextInput();
    return child;
  }
}

/// The underlying state implementation of CustTextInput
class _CustTextInput extends State<CustTextInput> {
  /// Controller of this object's input
  TextEditingController controller = TextEditingController();

  /// Whether this field is valid
  late bool _isValid;

  /// Whether to show hint or not
  bool showHint = true;

  // Used to not have to show invalid when a user hasn't yet entered anything
  /// Whether or not to show that this field is valid
  bool _showValid = true;

  @override
  void initState() {
    if (widget.options.validator != null) {
      _isValid = widget.options.validator!('');
    } else {
      _isValid = widget.options.validationRegex.hasMatch('');
    }
    super.initState();
  }

  /// Returns whether this input is currently valid
  bool isValid() {
    return _isValid;
  }

  /// Returns whether this input is currently fully empty
  bool isEmpty() {
    return getVal().isEmpty;
  }

  /// Clears this input
  void clear() {
    setState(() {
      _showValid = true;
      controller.clear();
      showHint = true;
    });
  }

//TODO: make nullable and return null if not valid (should be on this func)
  /// Returns the string value currently entered into the input
  String getVal() {
    return controller.text.toString();
  }

  @override
  Widget build(BuildContext context) {
    Widget? validIcon;
    if (widget.options.showValidSymbol && getVal().compareTo('') > 0) {
      validIcon = Icon(
          _showValid ? Icons.check_circle : Icons.flag_circle_rounded,
          size: 28,
          color: _showValid ? bc_style().correctcolor : bc_style().errorcolor);
    }
    // double width =
    //     widget.options.boxwidth ?? MediaQuery.of(context).size.width;
    // double height = widget.options.boxheight ?? 35;
    // return Text('baller');
    TextField tf = TextField(
      maxLines: widget.options.boxheight == null && !widget.options.obscureText
          ? null
          : 1,
      maxLength: widget.options.maxlines,
      controller: controller,
      obscureText: widget.options.obscureText,
      keyboardType: widget.options.keyboard,
      decoration: InputDecoration(
        suffixText: widget.options.suffixText,
        label: Text.rich(
          TextSpan(children: <InlineSpan>[
            WidgetSpan(
              child: Text(
                showHint ? widget.options.hint! : '',
              ),
            ),
          ]),
        ),
        errorText: _showValid ? null : widget.options.invalidText,
        //border: InputBorder.none,
        suffixIcon: validIcon,
        prefixIcon: widget.options.prefixIcon,
      ),
      onChanged: ((String str) {
        bool valid;
        if (widget.options.validator != null) {
          valid = widget.options.validator!(str);
        } else {
          valid = widget.options.validationRegex.hasMatch(str);
        }
        if (_isValid && !valid) {
          setState(() {
            _isValid = false;
          });
        } else if (!_isValid && valid) {
          setState(() {
            _isValid = true;
          });
        }
        if (_showValid && !valid) {
          setState(() {
            _showValid = false;
          });
        } else if (!_showValid && valid) {
          setState(() {
            _showValid = true;
          });
        }
      }),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Container(
          decoration: BoxDecoration(
            //color: bc_style().backgroundcolor,
            //border: Border.all(width: 5, color: bc_style().accent1color),
            borderRadius: BorderRadius.circular(5),
          ),
          padding:
              const EdgeInsets.only(bottom: 6, left: 5.0, right: 5.0, top: 6),
          child: (widget.options.boxwidth == null ||
                  widget.options.boxheight == null)
              ? tf
              : SizedBox(
                  child: tf,
                  width: widget.options.boxwidth,
                  height: widget.options.boxheight,
                )),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

class CustomPopupRoute extends PopupRoute {
  CustomPopupRoute({
    required this.builder,
    RouteSettings? settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;

  @override
  Color get barrierColor => Colors.black54.withAlpha(200);
  @override
  bool get barrierDismissible => true;
  @override
  String get barrierLabel => 'customPopupRoute';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

class CustDropdown extends StatefulWidget {
  _CustDropdown? child;
  ValueSetter<String> updateVal;
  List<String> optionList;
  String initVal;

  CustDropdown(this.optionList, this.updateVal, this.initVal, {super.key});

  @override
  State<CustDropdown> createState() {
    child = _CustDropdown();
    return child!;
  }
}

class _CustDropdown extends State<CustDropdown> {
  late String _curVal;

  @override
  initState() {
    _curVal = widget.initVal;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
        child: DropdownButton<String>(
          value: _curVal,
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 16,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              _curVal = value!;
              widget.updateVal(_curVal);
            });
          },
          items:
              widget.optionList.map<DropdownMenuItem<String>>((String value) {
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

@immutable

/// Represents the expandable log button on the home page
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          color: Theme.of(context).colorScheme.surfaceVariant,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4.0,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}

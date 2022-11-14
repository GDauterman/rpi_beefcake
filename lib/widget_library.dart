import 'package:flutter/material.dart';
import 'package:rpi_beefcake/firestore.dart';
import 'package:rpi_beefcake/style_lib.dart';
import 'dart:math' as math;


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
  final ServiceCallback dataEntry;
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
        label: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              WidgetSpan(
                  child: Text(
                      widget.options.hint!,
                  ),
              ),
            ]
          ),
        ),
        errorText: _isValid ? null : widget.options.invalidText,
        //border: InputBorder.none,
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
          //color: bc_style().backgroundcolor,
          //border: Border.all(width: 5, color: bc_style().accent1color),
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
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => builder(context);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child,) {
    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
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
          //color: bc_style().backgroundcolor,
          //border: Border.all(width: 5, color: bc_style().accent1color),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
        child: DropdownButton<String>(
          value: _curVal,
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 16,
          //style: TextStyle(color: bc_style().textcolor, fontSize: 24),
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

@immutable
class LogMenu extends StatelessWidget {
  static const _actionTitles = ['Log Sleep', 'Log Hydration', 'Log Nutrition'];

  const LogMenu({super.key});

  void _showAction(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_actionTitles[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => _showAction(context, 0),
            icon: const Icon(Icons.hotel),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 1),
            icon: const Icon(Icons.local_drink),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 2),
            icon: const Icon(Icons.fastfood),
          ),
        ],
      ),
    );
  }
}

@immutable
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

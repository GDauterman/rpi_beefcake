import 'package:flutter/material.dart';

/// Stateless widget to be shown when something is loading within the app
class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Material(
      color: Colors.black,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Loading',
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Courier New',
              fontFamilyFallback: <String>['Comic Sans'],
              fontSize: 50,
            )),
        Image.asset('images/loading_circle.gif', height: 125, width: 125),
      ]),
    ));
  }
}

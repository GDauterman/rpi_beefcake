import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

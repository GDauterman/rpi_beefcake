// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

class DummyPage extends StatelessWidget {
  const DummyPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Sub-Page'),
      ),
    );
  }
}
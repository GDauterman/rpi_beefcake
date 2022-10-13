// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:rpi_beefcake/base_page.dart';
import 'package:rpi_beefcake/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to BeefCake',
      theme: ThemeData(
        primarySwatch: Colors.pink
      ),
      home: const Scaffold(
        body: const BasePage(),
      ),
    );
  }
}

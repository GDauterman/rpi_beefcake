// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:rpi_beefcake/base_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firestore.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return const Text('uh oh');
        }
        else if(snapshot.connectionState == ConnectionState.done) {
          FirebaseService db = FirebaseService('gwd2018');
          return MaterialApp(
            title: 'Welcome to BeefCake',
            theme: ThemeData(
                primarySwatch: Colors.pink
            ),
            home: Scaffold(
              body: BasePage(db: db),
            ),
          );
        }
        return const Text('Loading', textDirection: TextDirection.ltr);
      },
    );
  }
}

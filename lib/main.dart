// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:rpi_beefcake/base_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rpi_beefcake/login_page.dart';
import 'firebase_options.dart';
import 'firestore.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  late final Future fbFuture = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseService? db;
  FirebaseAuth? auth;

  bool loggedIn = false;

  @override
  Widget build(BuildContext context) {


    return FutureBuilder(
      future: fbFuture,
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return const Text('uh oh');
        }
        else if(snapshot.connectionState == ConnectionState.done) {
          if(auth == null) {
            auth = FirebaseAuth.instance;
            auth!.authStateChanges().listen((User? user) {
              if (user == null) {
                setState(() {
                  loggedIn = false;
                  db = null;
                });
              } else {
                setState(() {
                  loggedIn = true;
                });
              }
            });
          }
          if(loggedIn) {
            db ??= FirebaseService(FirebaseAuth.instance.currentUser!.uid);
            return BasePage(db: db!);
          } else {
            return AllLogins();
          }
        }
        return Center(
          child: Column (
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Loading',
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Courier New',
                  fontFamilyFallback: <String>['Comic Sans'],
                  fontSize: 50,
                )),
              Image.asset('images/loading_circle.gif', height:125, width:125),
            ]
          ),
        );
      },
    );
  }
}

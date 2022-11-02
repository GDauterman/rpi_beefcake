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
import 'loading_page.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  late final Future fbFuture = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final GlobalKey<NavigatorState> mainNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> homeNavKey = GlobalKey<NavigatorState>();
  late final FirebaseService db;

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: fbFuture,
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return const Text('uh oh');
        }
        else if(snapshot.connectionState == ConnectionState.done) {
          db = FirebaseService();
          FirebaseAuth.instance.authStateChanges().listen((User? user) {
            if (user == null) {
              db.clearService();
              if (mainNavKey.currentState != null) {
                mainNavKey.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
              }
            } else {
              db.initService();
              if (mainNavKey.currentState != null) {
                mainNavKey.currentState!.pushNamedAndRemoveUntil('/', (route) => false);
              }
            }
          });
          return MaterialApp(
            title: 'Main App',
            navigatorKey: mainNavKey,
            initialRoute: '/login',
            routes: {
              '/':          (context) => BasePage(db: db, nk: homeNavKey),
              '/login':     (context) => const LoginPage(),
              '/register':  (context) => const RegisterPage(),
              '/loading':   (context) => LoadingPage(),
            },

          );
        }
        return LoadingPage();
      },
    );
  }
}

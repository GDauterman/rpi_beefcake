// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:rpi_beefcake/base_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rpi_beefcake/login_page.dart';
import 'package:rpi_beefcake/settings_page.dart';
import 'firebase_options.dart';
import 'firestore.dart';
import 'loading_page.dart';
import 'package:rpi_beefcake/style_lib.dart';


void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  late final Future fbFuture = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fbFuture,
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return const Text('uh oh');
        }
        else if(snapshot.connectionState == ConnectionState.done) {
          return NavPage();
        }
        return LoadingPage();
      },
    );
  }
}

class NavPage extends StatefulWidget {
  NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPage();
}

class _NavPage extends State<NavPage> {

  final GlobalKey<NavigatorState> mainNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> homeNavKey = GlobalKey<NavigatorState>();

  bool subscribedToAuth = false;

  bool isDark = false;

  void swapTheme() {
    setState(() { isDark = !isDark; });
  }

  void connetionStateChanges(bool connected) {
    if(connected) {
      mainNavKey.currentState!.pushNamedAndRemoveUntil('/', (route) => false);
    }
    mainNavKey.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget app = MaterialApp(
      title: 'Main App',
      theme: isDark ? customDarkTheme () : customLightTheme(),
      navigatorKey: mainNavKey,
      initialRoute: '/loading',
      routes: {
        '/':          (context) => BasePage(),
        '/login':     (context) => const LoginPage(),
        '/register':  (context) => const RegisterPage(),
        '/loading':   (context) => LoadingPage(),
        '/settings':  (context) => SettingsPage(swapTheme),
      },
    );

    //subscribes to authstate once (regardless of this page being rebuilt)
    if(!subscribedToAuth) {
      FirebaseService().addConnectedCallback((connected) {
        if(connected) {
          mainNavKey.currentState!.pushNamedAndRemoveUntil('/', (route) => false);
        } else {
          mainNavKey.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
        }
      });
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          print('clearing auth');
          FirebaseService().clearService();
        }
        else {
          print('init auth');
          FirebaseService().initService();
        }
      });
      subscribedToAuth = true;
    }

    return app;
  }

  // this would be where we would unsubscribe our authstatechanges listener (IF THEY GAVE US ONE)
  @override
  void deactivate() {
    super.deactivate();
  }

}


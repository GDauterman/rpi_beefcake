// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:rpi_beefcake/base_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rpi_beefcake/login_page.dart';
import 'package:rpi_beefcake/profile_page.dart';
import 'package:rpi_beefcake/settings_page.dart';
import 'firebase_options.dart';
import 'firestore.dart';
import 'loading_page.dart';
import 'package:rpi_beefcake/style_lib.dart';

// The starting point of the app
void main() {
  runApp(MainApp());
}

// Future builder for connecting to Firebase Server
class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  late final Future fbFuture =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    // Builds the man page once a connection to firebase is established
    // Until that connection is created, show loading page
    return FutureBuilder(
      future: fbFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw Exception('Unable to connect to Firebase servers');
        } else if (snapshot.connectionState == ConnectionState.done) {
          return NavPage();
        }
        return LoadingPage();
      },
    );
  }
}


/// A StatefulWidget class that starts our MaterialApp widget
///
/// Assumes connection to Firebase
///
/// State changes when dark mode is changed (on callback)
class NavPage extends StatefulWidget {
  NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPage();
}

/// Underlying State class for NavPage
class _NavPage extends State<NavPage> {
  /// The nagivation key for this widget, and by extension the rest of the app
  final GlobalKey<NavigatorState> mainNavKey = GlobalKey<NavigatorState>();

  /// Whether we have initialized an authcanges listener yet
  /// Listener has to be initialized after MaterialApp, so it can't fit in initState
  bool subscribedToAuth = false;

  /// Whether the app should be in Dark mode
  bool isDark = false;

  /// Inverts the theme of the app
  ///
  /// always sets state
  void swapTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  /// Sets current route based on value of [connected]
  void connetionStateChanges(bool connected) {
    if (connected) {
      mainNavKey.currentState!.pushNamedAndRemoveUntil('/', (route) => false);
    }
    mainNavKey.currentState!
        .pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget app = MaterialApp(
      title: 'Main App',
      theme: isDark ? customDarkTheme() : customLightTheme(),
      navigatorKey: mainNavKey,
      initialRoute: '/loading',
      routes: {
        '/': (context) => BasePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/loading': (context) => LoadingPage(),
        '/settings': (context) => SettingsPage(swapTheme),
        '/profile': (context) => ProfilePage(),
      },
    );

    // subscribes to FirebaseService connection change listener once (regardless of this page being rebuilt)
    // subscribes to authstatechange listener once (...)
    if (!subscribedToAuth) {
      FirebaseService().addConnectedCallback((connected) {
        if (connected) {
          mainNavKey.currentState!
              .pushNamedAndRemoveUntil('/', (route) => false);
        } else {
          mainNavKey.currentState!
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }
      });
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          print('clearing auth');
          FirebaseService().clearService();
        } else {
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

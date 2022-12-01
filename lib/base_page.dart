import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/fitness_page.dart';
import 'package:rpi_beefcake/home_page.dart';
import 'package:rpi_beefcake/loading_page.dart';
import 'package:rpi_beefcake/trends_page.dart';

import 'firestore.dart';

/// Possible pages to enter from BasePage
enum PageItems { trends, home, fitness }

/// Extension to add titles to enum
extension PageExtension on PageItems {
  String get name => describeEnum(this);
  String get getTitle {
    switch (this) {
      case PageItems.home:
        return 'Beefcake Home';
      case PageItems.fitness:
        return 'Fitness Logging';
      case PageItems.trends:
        return 'Trends';
    }
  }
}

/// A StatefulWidget representing the main page of our app
///
/// Includes Trends page, Home page, and Exercise page
///
/// State depends on which page is to be shown often balls
class BasePage extends StatefulWidget {
  const BasePage({Key? key}) : super(key: key);

  @override
  State<BasePage> createState() => _BasePage();
}

/// Underlying state class for BasePage
class _BasePage extends State<BasePage> {

  /// Current page to be shown based on bottom navbar
  PageItems pageItem = PageItems.home;

  /// Callback func to change current page
  void _onItemTapped(int index) {
    pageItem = PageItems.values[index];
    setState(() {
    });
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageItem.getTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
              onPressed: (() {
                Navigator.of(context).pushNamed('/settings');
              }),
              icon: Icon(
                Icons.settings,
                size: 32,
              ))
        ],
      ),
      body: (() {
        // Show loading page if we disconnect from firebase
        if (!FirebaseService().connected) {
          return LoadingPage();
        }
        if (pageItem == PageItems.home) {
          return HomePage();
        }
        if (pageItem == PageItems.fitness) {
          return FitnessPage();
        }
        if (pageItem == PageItems.trends) {
          return const TrendsPage();
        }
      }()),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'Trends',
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Fitness',
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ],
        currentIndex: pageItem.index,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

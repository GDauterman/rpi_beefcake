import 'package:flutter/material.dart';
import 'package:rpi_beefcake/fitness_page.dart';
import 'package:rpi_beefcake/health_page.dart';
import 'package:rpi_beefcake/home_page.dart';
import 'package:rpi_beefcake/page_enum.dart';
import 'package:rpi_beefcake/style_lib.dart';
import 'package:rpi_beefcake/trends_page.dart';
import 'package:rpi_beefcake/widget_library.dart';


class BasePage extends StatefulWidget {
  final GlobalKey<NavigatorState> nk;
  const BasePage(this.nk, {Key? key}) : super(key: key);

  @override
  State<BasePage> createState() => _BasePage();
}

class _BasePage extends State<BasePage> {
  static const _actionTitles = ["LogSleep", "logHydration", "logCalories", "logGoals"]; //set goals to be added
  bool? hideFab = true;

  PageItems pageItem = PageItems.health;
  void _showAction(BuildContext context, int index) {
      showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_actionTitles[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
    }

  void _onItemTapped(int index) {
    setState(() {
      if(index == PageItems.home.getIndex) {
        pageItem = PageItems.home;}
      if(index == PageItems.fitness.getIndex) {
        pageItem = PageItems.fitness;}
      if(index == PageItems.health.getIndex) {
        pageItem = PageItems.health;}
      if(index == PageItems.trends.getIndex) {
        pageItem = PageItems.trends;}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageItem.getTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
              onPressed: (() {widget.nk.currentState!.pushNamed('/settings');}),
              icon: Icon(Icons.settings, size: 32,))
        ],
      ),
      body: (() {
        if(pageItem == PageItems.home) {
          return HomePage();}
        if(pageItem == PageItems.fitness) {
          return FitnessPage();}
        if(pageItem == PageItems.health) {
          return HealthPage();}
        if(pageItem == PageItems.trends) {
          return const TrendsPage();}
      } ()),
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => _showAction(context, 0),
            icon: const Icon(Icons.hotel),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 1),
            icon: const Icon(Icons.local_drink),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 2),
            icon: const Icon(Icons.fastfood),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 2),
            icon: const Icon(Icons.monitor_weight),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        items: <BottomNavigationBarItem>[
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
          BottomNavigationBarItem(
            icon: Icon(Icons.heart_broken),
            label: 'Health',
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'Trends',
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ],
        currentIndex: pageItem.getIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
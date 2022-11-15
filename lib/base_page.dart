import 'package:flutter/material.dart';
import 'package:rpi_beefcake/fitness_page.dart';
import 'package:rpi_beefcake/health_page.dart';
import 'package:rpi_beefcake/home_page.dart';
import 'package:rpi_beefcake/loading_page.dart';
import 'package:rpi_beefcake/page_enum.dart';
import 'package:rpi_beefcake/trends_page.dart';

import 'firestore.dart';


class BasePage extends StatefulWidget {
  const BasePage({Key? key}) : super(key: key);

  @override
  State<BasePage> createState() => _BasePage();
}

class _BasePage extends State<BasePage> {
  PageItems pageItem = PageItems.home;

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
              onPressed: (() {Navigator.of(context).pushNamed('/settings');}),
              icon: Icon(Icons.settings, size: 32,))
        ],
      ),
      body: (() {
        if(!FirebaseService().connected) {
          return LoadingPage();}
        if(pageItem == PageItems.home) {
          return HomePage();}
        if(pageItem == PageItems.fitness) {
          return FitnessPage();}
        if(pageItem == PageItems.health) {
          return HealthPage();}
        if(pageItem == PageItems.trends) {
          return const TrendsPage();}
      } ()),
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
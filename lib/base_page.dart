import 'package:flutter/material.dart';
import 'package:rpi_beefcake/fitness_page.dart';
import 'package:rpi_beefcake/health_page.dart';
import 'package:rpi_beefcake/home_page.dart';
import 'package:rpi_beefcake/tab_navigator.dart';
import 'package:rpi_beefcake/trends_page.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageItem.getTitle),
        backgroundColor: pageItem.getColor,
      ),
      body: (() {
        if(pageItem == PageItems.home) {
          return const HomePage();}
        if(pageItem == PageItems.fitness) {
          return const FitnessPage();}
        if(pageItem == PageItems.health) {
          return const HealthPage();}
        if(pageItem == PageItems.trends) {
          return const TrendsPage();}
      } ()),
      // ToDo: make navbar use page enum colors
      //  (needs to be const) currently hardcoded
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_gymnastics),
            label: 'Fitness',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.heart_broken),
            label: 'Health',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'Trends',
            backgroundColor: Colors.teal,
          ),
        ],
        currentIndex: pageItem.getIndex,
        selectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),

    );
  }
}
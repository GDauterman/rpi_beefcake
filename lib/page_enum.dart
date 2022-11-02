import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// class PageNavigatorRoutes {
//   static const String base_page = '/';
//   static const String sub_page = '/sub_page';
// }

enum PageItems { home, fitness, health, trends }
extension PageExtension on PageItems {
  String get name => describeEnum(this);
  String get getTitle {
    switch (this) {
      case PageItems.home:
        return 'Beefcake Home';
      case PageItems.fitness:
        return 'Fitness Logging';
      case PageItems.health:
        return 'Health Logging';
      case PageItems.trends:
        return 'Trends';
    }
  }
  Color get getColor {
    switch (this) {
      case PageItems.home:
        return Colors.black54;
      case PageItems.fitness:
        return Colors.blue;
      case PageItems.health:
        return Colors.green;
      case PageItems.trends:
        return Colors.teal;
    }
  }
  int get getIndex {
    switch (this) {
      case PageItems.home:
        return 0;
      case PageItems.fitness:
        return 1;
      case PageItems.health:
        return 2;
      case PageItems.trends:
        return 3;
    }
  }
}
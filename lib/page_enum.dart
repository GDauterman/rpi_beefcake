import 'package:flutter/foundation.dart';

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
  int get getIndex {
    switch (this) {
      case PageItems.home:
        return 0;
      case PageItems.fitness:
        return 1;
      case PageItems.trends:
        return 2;
      default:
        return 0;
    }
  }
}
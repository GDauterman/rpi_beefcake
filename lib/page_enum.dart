import 'package:flutter/foundation.dart';

enum PageItems { trends, home, fitness }
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
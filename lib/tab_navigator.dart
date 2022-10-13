import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rpi_beefcake/base_page.dart';
import 'package:rpi_beefcake/dummy_sub_page.dart';

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
        return Colors.white;
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

// class PageNavigator extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _PageNavigator();
// }
//
// class _PageNavigator extends State<PageNagivator> {
//
//   Map<PageItems, GlobalKey<NavigatorState>> navigatorKeys = {
//     PageItems.home: GlobalKey<NavigatorState>(),
//     PageItems.fitness: GlobalKey<NavigatorState>(),
//     PageItems.health: GlobalKey<NavigatorState>(),
//     PageItems.trends: GlobalKey<NavigatorState>(),
//   };
//
//   Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
//     return {
//       PageNavigatorRoutes.base_page: (context) => BasePage(),
//       PageNavigatorRoutes.sub_page: (context) => DummyPage(),
//     };
//   }
//
//   void _push(BuildContext context) {
//     var routeBuilders = _routeBuilders(context);
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => routeBuilders[PageNavigatorRoutes.sub_page](context)
//       )
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var routeBuilders = _routeBuilders(context);
//
//     return Navigator(
//       key: navigatorKey,
//       initialRoute: PageNavigatorRoutes.base_page,
//       onGenerateRoute: (routeSettings) {
//         return MaterialPageRoute(
//           builder: (context) => routeBuilders[routeSettings.name](context)
//         );
//       }
//     )
//   }
// }

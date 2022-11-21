import 'dart:ui';
import 'package:flutter/material.dart';

ThemeData customLightTheme() {
  TextTheme _customLightThemesTextTheme(TextTheme base) {
    return base.copyWith(
      button: base.button?.copyWith(
        //fontFamily: ‘Roboto’,
        fontSize: 26.0,
        color: Colors.white,
      ),
      headline6: base.headline6?.copyWith(fontSize: 15.0, color: Colors.orange),
      headline4: base.headline1?.copyWith(
        fontSize: 20.0,
      ),
      headline3:
          base.headline1?.copyWith(fontSize: 35, fontWeight: FontWeight.bold),
      headline2: base.headline1?.copyWith(
        fontSize: 14,
      ),
      caption: base.caption?.copyWith(
        color: const Color(0xFFCCC5AF),
      ),
      bodyText2: base.bodyText2?.copyWith(color: const Color(0xFF807A6B)),
      bodyText1: base.bodyText1?.copyWith(color: Colors.brown),
    );
  }

  final ThemeData lightTheme = ThemeData.light();
  return lightTheme.copyWith(
      colorScheme: lightTheme.colorScheme.copyWith(
          //primary colors
          primary: const Color(0xFFDB643E),
          primaryContainer: const Color(0xFFFF9876),
          onPrimary: const Color(0xFFFFFFFF),
          onPrimaryContainer: const Color(0xFF3A0A00),

          //secondary colors
          secondary: const Color(0xFF77574E),
          secondaryContainer: const Color(0xFFFF9876),
          onSecondary: const Color(0xFFFFFFFF),
          onSecondaryContainer: const Color(0xFF2C150F),

          //error colors
          error: const Color(0xFFBA1A1A),
          errorContainer: const Color(0xFFFFDAD6),
          onError: const Color(0xFFFFFFFF),
          onErrorContainer: const Color(0xFF410002),

          //neutral colors
          background: const Color(0xFFFFFBFF),
          surface: const Color(0xFFFFFBFF),
          onBackground: const Color(0xFF201A18),
          onSurface: const Color(0xFF201A18),

          //neutral variant colors
          surfaceVariant: const Color(0xFFFFB197),
          outline: const Color(0xFF85736E),
          onSurfaceVariant: const Color(0xFF53433F),
          shadow: const Color(0xFF000000),

          //inverse colors
          inverseSurface: const Color(0xFF362F2D),
          onInverseSurface: const Color(0xFFFBEEEB),
          inversePrimary: const Color(0xFFFFB5A0)),
      textTheme: _customLightThemesTextTheme(lightTheme.textTheme),
      indicatorColor: const Color(0xFF807A6B),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      primaryIconTheme: lightTheme.primaryIconTheme.copyWith(
        color: Colors.white,
        size: 20,
      ),
      iconTheme: lightTheme.iconTheme.copyWith(
        color: Colors.white,
      ),
      backgroundColor: Colors.indigo,
      tabBarTheme: lightTheme.tabBarTheme.copyWith(
        labelColor: const Color(0xffce107c),
        unselectedLabelColor: Colors.grey,
      ),
      buttonTheme: lightTheme.buttonTheme.copyWith(buttonColor: Colors.red),
      errorColor: Colors.red,
      visualDensity: VisualDensity.standard);
}

ThemeData customDarkTheme() {
  final ThemeData darkTheme = ThemeData.dark();
  TextTheme _customDarkThemesTextTheme(TextTheme base) {
    return base.copyWith(
      button: base.button?.copyWith(
        //fontFamily: ‘Roboto’,
        fontSize: 30.0,
        color: Colors.white,
      ),
      headline6: base.headline6?.copyWith(fontSize: 15.0, color: Colors.orange),
      headline4: base.headline1?.copyWith(
        fontSize: 20.0,
        color: Colors.white,
      ),
      headline3: base.headline1?.copyWith(
          color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold),
      headline2: base.headline1?.copyWith(
        color: Colors.white,
        fontSize: 14,
      ),
      caption: base.caption?.copyWith(
        color: const Color(0xFFCCC5AF),
      ),
      bodyText2: base.bodyText2?.copyWith(color: const Color(0xFF807A6B)),
      bodyText1: base.bodyText1?.copyWith(color: Colors.brown),
    );
  }

  return darkTheme.copyWith(
      colorScheme: darkTheme.colorScheme.copyWith(
          //primary colors
          primary: const Color(0xFFA02799),
          primaryContainer: const Color(0xFFFFD7F3),
          onPrimary: const Color(0xFFFFFFFF),
          onPrimaryContainer: const Color(0xFF390036),

          //secondary colors
          secondary: const Color(0xFFBBC7DB),
          secondaryContainer: const Color(0xFF3B4858),
          onSecondary: const Color(0xFF253140),
          onSecondaryContainer: const Color(0xFFD7E3F7),

          //error colors
          error: const Color(0xFFFFb4AB),
          errorContainer: const Color(0xFF93000A),
          onError: const Color(0xFF690005),
          onErrorContainer: const Color(0xFFFFB4AB),

          //neutral colors
          background: const Color(0xFF1A1C1E),
          surface: const Color(0xFF1A1C1E),
          onBackground: const Color(0xFFE2E2E6),
          onSurface: const Color(0xFFE2E2E6),

          //neutral variant colors
          surfaceVariant: const Color(0xFF43474E),
          outline: const Color(0xFF8D9199),
          onSurfaceVariant: const Color(0xFFC3C7CF),
          shadow: const Color(0xFF000000),

          //inverse colors
          inverseSurface: const Color(0xFFE2E2E6),
          onInverseSurface: const Color(0xFF2F3033),
          inversePrimary: const Color(0xFF0061A4)),
      textTheme: _customDarkThemesTextTheme(darkTheme.textTheme),
      indicatorColor: Colors.green,
      primaryIconTheme: darkTheme.primaryIconTheme.copyWith(
        color: Colors.grey[600],
        size: 20,
      ),
      iconTheme: darkTheme.iconTheme.copyWith(
        color: Colors.grey[600],
      ),
      //backgroundColor: darkTheme.backgroundColor,
      tabBarTheme: darkTheme.tabBarTheme.copyWith(
        labelColor: const Color(0xffce107c),
        unselectedLabelColor: Colors.grey,
      ),
      buttonTheme:
          darkTheme.buttonTheme.copyWith(buttonColor: const Color(0xDD5FD0)),
      errorColor: Colors.red,
      visualDensity: VisualDensity.standard);
}

class bc_style {
  final Color backgroundcolor = Colors.white;
  final Color accent1color = Colors.green;
  final Color accent2color = Colors.indigo;
  final Color textcolor = Colors.black;
  final Color errorcolor = Colors.red;
  final Color correctcolor = Colors.greenAccent;

  const bc_style();
}

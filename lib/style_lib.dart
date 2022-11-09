import 'dart:ui';
import 'package:flutter/material.dart';

ThemeData customLightTheme() {

  TextTheme _customLightThemesTextTheme(TextTheme base) {
    return base.copyWith(
      button: base.button?.copyWith(
        //fontFamily: ‘Roboto’,
        fontSize: 30.0,
        color: Colors.white,
      ),
      headline6: base.headline6?.copyWith(
          fontSize: 15.0,
          color: Colors.orange
      ),
      headline4: base.headline1?.copyWith(
        fontSize: 24.0,
        color: Colors.white,
      ),
      headline3: base.headline1?.copyWith(
        fontSize: 22.0,
        color: Colors.grey,
      ),
      caption: base.caption?.copyWith(
        color: Color(0xFFCCC5AF),
      ),
      bodyText2: base.bodyText2?.copyWith(color: Color(0xFF807A6B)),
      bodyText1: base.bodyText1?.copyWith(color: Colors.brown),
    );
  }

  final ThemeData lightTheme = ThemeData.light();
  return lightTheme.copyWith(
    colorScheme: lightTheme.colorScheme.copyWith(
        primary: Colors.indigo,
        background: Colors.indigo,
        surfaceVariant: Colors.indigo,
        secondary: Colors.pink[100]
    ),
    textTheme: _customLightThemesTextTheme(lightTheme.textTheme),
    indicatorColor: Color(0xFF807A6B),
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    primaryIconTheme: lightTheme.primaryIconTheme.copyWith(
      color: Colors.white,
      size: 20,
    ),
    iconTheme: lightTheme.iconTheme.copyWith(
      color: Colors.white,
    ),
    backgroundColor: Colors.indigo,
    tabBarTheme: lightTheme.tabBarTheme.copyWith(
      labelColor: Color(0xffce107c),
      unselectedLabelColor: Colors.grey,
    ),
    buttonTheme: lightTheme.buttonTheme.copyWith(buttonColor: Colors.red),
    errorColor: Colors.red,
  );
}

ThemeData customDarkTheme() {
  TextTheme _customDarkThemesTextTheme(TextTheme base) {
    return base.copyWith(
      button: base.button?.copyWith(
        //fontFamily: ‘Roboto’,
        fontSize: 30.0,
        color: Colors.white,
      ),
      headline6: base.headline6?.copyWith(
          fontSize: 15.0,
          color: Colors.orange
      ),
      headline4: base.headline1?.copyWith(
        fontSize: 24.0,
        color: Colors.white,
      ),
      headline3: base.headline1?.copyWith(
        fontSize: 22.0,
        color: Colors.grey,
      ),
      caption: base.caption?.copyWith(
        color: Color(0xFFCCC5AF),
      ),
      bodyText2: base.bodyText2?.copyWith(color: Color(0xFF807A6B)),
      bodyText1: base.bodyText1?.copyWith(color: Colors.brown),
    );
  }
  final ThemeData darkTheme = ThemeData.dark();
  return darkTheme.copyWith(
    colorScheme: darkTheme.colorScheme.copyWith(
        //neutral colors
        //background: Color(0x1A1C1E),
        //onBackground: Color(0xE2E2E6),

        //primary colors
        primary: Colors.purple[800],
        secondary: Colors.purple[400]

    ),
    textTheme: _customDarkThemesTextTheme(darkTheme.textTheme),
    indicatorColor: Colors.green,
    primaryIconTheme: darkTheme.primaryIconTheme.copyWith(
      color: Colors.grey[600],
      size: 20,
    ),
    iconTheme: darkTheme.iconTheme.copyWith(
      color: Colors.grey[600],
    ),
    backgroundColor: darkTheme.backgroundColor,
    tabBarTheme: darkTheme.tabBarTheme.copyWith(
      labelColor: Color(0xffce107c),
      unselectedLabelColor: Colors.grey,
    ),
    buttonTheme: darkTheme.buttonTheme.copyWith(buttonColor: Colors.red),
    errorColor: Colors.red,
  );
}


class bc_style {
  final Color backgroundcolor =    Colors.white;
  final Color accent1color =       Colors.green;
  final Color accent2color =       Colors.indigo;
  final Color textcolor =     Colors.black;
  final Color errorcolor =    Colors.red;
  final Color correctcolor =  Colors.greenAccent;

  const bc_style();
}
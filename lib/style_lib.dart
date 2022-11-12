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
      //primary colors
        primary: Color(0xFFDB643E),
        primaryContainer: Color(0xFFFF9876),
        onPrimary: Color(0xFFFFFFFF),
        onPrimaryContainer: Color(0xFF3A0A00),

        //secondary colors
        secondary: Color(0xFF77574E),
        secondaryContainer: Color(0xFFFF9876),
        onSecondary: Color(0xFFFFFFFF),
        onSecondaryContainer: Color(0xFF2C150F),

        //error colors
        error: Color(0xFFBA1A1A),
        errorContainer: Color(0xFFFFDAD6),
        onError: Color(0xFFFFFFFF),
        onErrorContainer: Color(0xFF410002),

        //neutral colors
        background: Color(0xFFFFFBFF),
        surface: Color(0xFFFFFBFF),
        onBackground: Color(0xFF201A18),
        onSurface: Color(0xFF201A18),

        //neutral variant colors
        surfaceVariant: Color(0xFFFFB197),
        outline: Color(0xFF85736E),
        onSurfaceVariant: Color(0xFF53433F),
        shadow: Color(0xFF000000),

        //inverse colors
        inverseSurface: Color(0xFF362F2D),
        onInverseSurface: Color(0xFFFBEEEB),
        inversePrimary: Color(0xFFFFB5A0)
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
  final ThemeData darkTheme = ThemeData.dark();
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

  return darkTheme.copyWith(
    colorScheme: darkTheme.colorScheme.copyWith(
        //primary colors
        primary: Color(0xFFA02799),
        primaryContainer: Color(0xFFFFD7F3),
        onPrimary: Color(0xFFFFFFFF),
        onPrimaryContainer: Color(0xFF390036),

        //secondary colors
        secondary: Color(0xFFBBC7DB),
        secondaryContainer: Color(0xFF3B4858),
        onSecondary: Color(0xFF253140),
        onSecondaryContainer: Color(0xFFD7E3F7),

        //error colors
        error: Color(0xFFFFb4AB),
        errorContainer: Color(0xFF93000A),
        onError: Color(0xFF690005),
        onErrorContainer: Color(0xFFFFB4AB),

        //neutral colors
        background: Color(0xFF1A1C1E),
        surface: Color(0xFF1A1C1E),
        onBackground: Color(0xFFE2E2E6),
        onSurface: Color(0xFFE2E2E6),

        //neutral variant colors
        surfaceVariant: Color(0xFF43474E),
        outline: Color(0xFF8D9199),
        onSurfaceVariant: Color(0xFFC3C7CF),
        shadow: Color(0xFF000000),

        //inverse colors
        inverseSurface: Color(0xFFE2E2E6),
        onInverseSurface: Color(0xFF2F3033),
        inversePrimary: Color(0xFF0061A4)
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
    //backgroundColor: darkTheme.backgroundColor,
    tabBarTheme: darkTheme.tabBarTheme.copyWith(
      labelColor: Color(0xffce107c),
      unselectedLabelColor: Colors.grey,
    ),
    buttonTheme: darkTheme.buttonTheme.copyWith(buttonColor:  Color(0xDD5FD0)),
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
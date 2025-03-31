import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  ),

  textTheme: _textTheme,
);

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),

  textTheme: _textTheme,
);

TextTheme _textTheme = TextTheme(
  titleSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  titleMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  titleLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
);

import 'package:flutter/material.dart';

class Themes {
  static final lightTheme = ThemeData(
    fontFamily: "Sans",
    colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.yellow,
        brightness: Brightness.light,
        cardColor: Colors.white),
    bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey[50]),
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(backgroundColor: Colors.yellow),
    dialogTheme: const DialogTheme(shadowColor: Colors.white),
    useMaterial3: true,
  );
}

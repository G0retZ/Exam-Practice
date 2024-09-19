import 'package:flutter/material.dart';

class Palette {
  static const purple80 = Color(0xFFD0BCFF);
  static const purpleGrey80 = Color(0xFFCCC2DC);
  static const pink80 = Color(0xFFEFB8C8);

  static const purple40 = Color(0xFF6650a4);
  static const purpleGrey40 = Color(0xFF625b71);
  static const pink40 = Color(0xFF7D5260);
  static const unspecified = Color.fromARGB(0, 0, 0, 0);

  static Color getPassed(BuildContext context) => _isDarkMode(context)
      ? const Color.fromARGB(255, 0, 192, 0)
      : const Color.fromARGB(255, 0, 160, 0);

  static Color getFailed(BuildContext context) => _isDarkMode(context)
      ? const Color.fromARGB(255, 255, 80, 80)
      : const Color.fromARGB(255, 255, 0, 0);

  static Color getCorrect(BuildContext context) => _isDarkMode(context)
      ? const Color.fromARGB(64, 128, 192, 128)
      : const Color.fromARGB(20, 0, 192, 0);

  static Color getIncorrect(BuildContext context) => _isDarkMode(context)
      ? const Color.fromARGB(64, 255, 128, 128)
      : const Color.fromARGB(20, 255, 0, 0);

  static Color getMissed(BuildContext context) => _isDarkMode(context)
      ? const Color.fromARGB(64, 255, 160, 80)
      : const Color.fromARGB(20, 255, 160, 0);

  static Color getCorrectStrong(BuildContext context) => _isDarkMode(context)
      ? const Color.fromARGB(64, 0, 192, 0)
      : const Color.fromARGB(64, 0, 192, 0);

  static Color getIncorrectStrong(BuildContext context) => _isDarkMode(context)
      ? const Color.fromARGB(80, 255, 64, 64)
      : const Color.fromARGB(64, 255, 0, 0);

  static Color getMissedStrong(BuildContext context) => _isDarkMode(context)
      ? const Color.fromARGB(64, 192, 128, 255)
      : const Color.fromARGB(20, 128, 0, 192);

  static Color getSelectedStrong(BuildContext context) => _isDarkMode(context)
      ? const Color.fromARGB(64, 64, 192, 255)
      : const Color.fromARGB(64, 0, 128, 192);

  static bool _isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}

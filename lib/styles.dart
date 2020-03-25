import 'package:flutter/material.dart';

abstract class HabitTypeStyle {
  Text label;
  TextStyle selectedLabelStyle;
  Color selectedBackgroundColor;
}

class PositiveHabitTypeStyle extends HabitTypeStyle {
  Text label = Text("Полезная");
  TextStyle selectedLabelStyle = TextStyle(color: Colors.green.shade700);
  Color selectedBackgroundColor = Colors.green.shade100;
}

class NegativeHabitTypeStyle extends HabitTypeStyle {
  Text label = Text("Вредная");
  TextStyle selectedLabelStyle = TextStyle(color: Colors.red.shade700);
  Color selectedBackgroundColor = Colors.red.shade100;
}

class NeutralHabitTypeStyle extends HabitTypeStyle {
  Text label = Text("Нейтральная");
  TextStyle selectedLabelStyle = TextStyle(color: Colors.white);
  Color selectedBackgroundColor = Colors.grey.shade600;
}
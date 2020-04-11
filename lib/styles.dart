import 'package:flutter/material.dart';

import 'logic/habit/db.dart';

class HabitTypeChipStyle {
  Text label;
  Color textColor;
  Color background;

  HabitTypeChipStyle({this.label, this.textColor, this.background});
}

class HabitTypeCounterStyle {
  Color zeroBackgroundColor;
  Color nonZeroBackgroundColor;
  TextStyle textStyle;

  HabitTypeCounterStyle({
    this.zeroBackgroundColor,
    this.nonZeroBackgroundColor,
    this.textStyle: const TextStyle(color: Colors.white70),
  });
}

class HabitTypeTheme {
  Color primaryColor;
  HabitTypeChipStyle chipStyle;
  HabitTypeCounterStyle counterStyle;

  HabitTypeTheme({this.primaryColor, this.chipStyle, this.counterStyle}) {
    this.chipStyle.textColor = this.chipStyle.textColor ?? this.primaryColor;
    this.chipStyle.background = this.chipStyle.background ?? this.primaryColor;
  }
}

Map<HabitType, HabitTypeTheme> HabitTypeThemeMap = {
  HabitType.positive: HabitTypeTheme(
    primaryColor: Colors.green.shade500,
    chipStyle: HabitTypeChipStyle(
        label: Text("Полезная"),
        background: Colors.green.shade100,
        textColor: Colors.green.shade700),
    counterStyle: HabitTypeCounterStyle(
      zeroBackgroundColor: Colors.grey.shade400,
      nonZeroBackgroundColor: Colors.green.shade700,
    ),
  ),
  HabitType.negative: HabitTypeTheme(
    primaryColor: Colors.red.shade500,
    chipStyle: HabitTypeChipStyle(
      label: Text("Вредная"),
      background: Colors.red.shade100,
    ),
    counterStyle: HabitTypeCounterStyle(
      zeroBackgroundColor: Colors.green.shade700,
      nonZeroBackgroundColor: Colors.red.shade700,
    ),
  ),
  HabitType.neutral: HabitTypeTheme(
    primaryColor: Colors.grey.shade400,
    chipStyle: HabitTypeChipStyle(
      label: Text("Нейтральная"),
      textColor: Colors.white,
    ),
    counterStyle: HabitTypeCounterStyle(
      zeroBackgroundColor: Colors.grey.shade400,
      nonZeroBackgroundColor: Colors.grey.shade400,
    ),
  ),
};


import 'package:flutter/material.dart';

import 'logic/habit/db.dart';

class HabitTypeChipStyle {
  Text label;
  TextStyle textStyle;
  Color background;

  HabitTypeChipStyle(this.label, this.textStyle, this.background);
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
  HabitTypeChipStyle chipStyle;
  HabitTypeCounterStyle counterStyle;

  HabitTypeTheme(this.chipStyle, this.counterStyle);
}

Map<HabitType, HabitTypeTheme> HabitTypeThemeMap = {
  HabitType.positive: HabitTypeTheme(
    HabitTypeChipStyle(
      Text("Полезная"),
      TextStyle(color: Colors.green.shade700),
      Colors.green.shade100,
    ),
    HabitTypeCounterStyle(
      zeroBackgroundColor: Colors.grey.shade400,
      nonZeroBackgroundColor: Colors.green.shade700,
    ),
  ),
  HabitType.negative: HabitTypeTheme(
    HabitTypeChipStyle(
      Text("Вредная"),
      TextStyle(color: Colors.red.shade700),
      Colors.red.shade100,
    ),
    HabitTypeCounterStyle(
      zeroBackgroundColor: Colors.green.shade700,
      nonZeroBackgroundColor: Colors.red.shade700,
    ),
  ),
  HabitType.neutral: HabitTypeTheme(
    HabitTypeChipStyle(
      Text("Нейтральная"),
      TextStyle(color: Colors.white),
      Colors.grey.shade600,
    ),
    HabitTypeCounterStyle(
      zeroBackgroundColor: Colors.grey.shade400,
      nonZeroBackgroundColor: Colors.grey.shade400,
    ),
  ),
};

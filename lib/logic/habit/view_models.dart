import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yahta/logic/core/view_models.dart';

import 'db.dart';

part 'view_models.freezed.dart';

class HabitViewModel {
  Habit habit;
  List<HabitMark> habitMarks;

  HabitViewModel(this.habit, this.habitMarks);
}

@freezed
abstract class HabitMarkFrequency with _$HabitMarkFrequency {
  factory HabitMarkFrequency({DateTime date, int freq}) =
      _HabitMarkFrequency;
}

class HabitMarkSeries {
  List<HabitMark> habitMarks;

  HabitMarkSeries(this.habitMarks);

  List<HabitMarkFrequency> get series => groupBy<HabitMark, DateTime>(
        habitMarks,
        (mark) => DayDateTimeRange(mark.datetime).fromDateTime,
      )
          .entries
          .map(
            (e) => HabitMarkFrequency(date: e.key, freq: e.value.length),
          )
          .toList();
}

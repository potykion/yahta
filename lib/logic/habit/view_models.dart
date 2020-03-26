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
  factory HabitMarkFrequency({DateTime date, int freq}) = _HabitMarkFrequency;
}

class HabitMarkSeries {
  List<HabitMark> habitMarks;
  WeekDateRange weekDateRange;

  HabitMarkSeries(this.habitMarks, this.weekDateRange);

  List<HabitMarkFrequency> get series {
    var freqMap = groupBy<HabitMark, DateTime>(
      habitMarks,
      (mark) => DayDateTimeRange(mark.datetime).fromDateTime,
    );

    this
        .weekDateRange
        .dates
        .forEach((date) => freqMap.putIfAbsent(date, () => []));

    return freqMap.entries
        .map((e) => HabitMarkFrequency(date: e.key, freq: e.value.length))
        .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
  }
}

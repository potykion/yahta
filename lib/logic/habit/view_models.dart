import 'dart:math';

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
    var freqMap = {};

    if (habitMarks.length <= 0) {
      this
          .weekDateRange
          .dates
          .forEach((date) => freqMap.putIfAbsent(date, () => null));
    } else {
      var sortedHabitMarks = habitMarks
        ..sort((a, b) => a.datetime.compareTo(b.datetime));
      // todo заменить на Habit.creationDate и currentDate
      var minDateTime = DateTimeStart(sortedHabitMarks.first.datetime).dateTime;
      var maxDateTime = DateTimeStart(sortedHabitMarks.last.datetime).dateTime;

      freqMap = groupBy<HabitMark, DateTime>(
        sortedHabitMarks,
        (mark) => DayDateTimeRange(mark.datetime).fromDateTime,
      );

      this
          .weekDateRange
          .dates
          .where((date) => date.isBefore(minDateTime) || date.isAfter(maxDateTime))
          .forEach((date) => freqMap.putIfAbsent(date, () => null));

    this
        .weekDateRange
        .dates
        .where((date) => date.isBefore(maxDateTime) || date.isAfter(minDateTime))
        .forEach((date) => freqMap.putIfAbsent(date, () => <HabitMark>[]));
    }

    return freqMap.entries
        .map((e) => HabitMarkFrequency(
            date: e.key, freq: e.value != null ? e.value.length : null))
        .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
  }

  get maxFreq {
    var freqs = this.series.map((s) => s.freq).where((freq) => freq != null);
    return freqs.length > 0 ? freqs.reduce(max) : 0;
  }
}

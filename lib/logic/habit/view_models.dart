import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yahta/logic/core/date.dart';

import 'db.dart';

part 'view_models.freezed.dart';

class HabitListViewModel {
  Habit habit;
  List<HabitMark> habitMarks;
  DateTime latestMarkDateBeforeToday;

  HabitListViewModel(this.habit, {this.habitMarks, latestMarkDateBeforeToday})
      : latestMarkDateBeforeToday = latestMarkDateBeforeToday ?? DateTime.now();

  bool get noUpdatesInTwoDays =>
      DateTime.now().difference(this.latestMarkDateBeforeToday).inDays >= 2;
}

@freezed
abstract class HabitMarkFrequency with _$HabitMarkFrequency {
  factory HabitMarkFrequency({DateTime date, int freq}) = _HabitMarkFrequency;
}

/// Генерит данные для построения графика (с учетом пустышек и нуликов)
/// Пустышки - это то, что перед точкой A (minDateTime) и после точки C (maxDateTime)
/// Нулики - это то, что на оси X между A и C (например, точка B) - то есть 0 - то есть отметки привычки в этот день не было
///
/// ^
/// |
/// |                C
/// |        .     /
/// |      /  \  /
/// +----A-----B--------->
class HabitMarkSeries {
  // todo rename to dates / frequencies & rename class to WeekFrequencyChartSeries
  List<HabitMark> habitMarks;
  WeekDateRange weekDateRange;
  DateTime minDateTime;
  DateTime maxDateTime;

  HabitMarkSeries(
    this.habitMarks,
    this.weekDateRange,
    this.minDateTime,
    this.maxDateTime,
  );

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

      freqMap = groupBy<HabitMark, DateTime>(
        sortedHabitMarks,
        (mark) => DayDateTimeRange(mark.datetime).fromDateTime,
      );

      this
          .weekDateRange
          .dates
          .where(
              (date) => date.isBefore(minDateTime) || date.isAfter(maxDateTime))
          .forEach((date) => freqMap.putIfAbsent(date, () => null));

      this
          .weekDateRange
          .dates
          .where(
              (date) => date.isBefore(maxDateTime) || date.isAfter(minDateTime))
          .forEach((date) => freqMap.putIfAbsent(date, () => <HabitMark>[]));
    }

    // todo ленгз можно сразу получить мб
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

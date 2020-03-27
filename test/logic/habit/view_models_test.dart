import 'package:flutter_test/flutter_test.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/db.dart';
import 'package:yahta/logic/habit/view_models.dart';

void main() {
  group("Тестим вью-модели", () {
    test("Группировка привычек по дате", () async {
      var marks = [
        HabitMark(id: 1, habitId: 1, datetime: DateTime(2020, 3, 19)),
        HabitMark(id: 2, habitId: 1, datetime: DateTime(2020, 3, 19)),
        HabitMark(id: 3, habitId: 1, datetime: DateTime(2020, 3, 21)),
      ];

      var weekDateRange = WeekDateRange(DateTime(2020, 3, 20));

      var series = HabitMarkSeries(
          marks, weekDateRange,
          DateTime(2020, 3, 19), DateTime(2020, 3, 21)
      );
      expect(series.series, [
        // todo лучше чтоб было null
        HabitMarkFrequency(date: DateTime(2020, 3, 16), freq: 0),
        HabitMarkFrequency(date: DateTime(2020, 3, 17), freq: 0),
        HabitMarkFrequency(date: DateTime(2020, 3, 18), freq: 0),
        HabitMarkFrequency(date: DateTime(2020, 3, 19), freq: 2),
        HabitMarkFrequency(date: DateTime(2020, 3, 20), freq: 0),
        HabitMarkFrequency(date: DateTime(2020, 3, 21), freq: 1),
        HabitMarkFrequency(date: DateTime(2020, 3, 22), freq: null),
      ]);
      expect(series.maxFreq, 2);
    });
  });
}

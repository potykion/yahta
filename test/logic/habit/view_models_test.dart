import 'package:flutter_test/flutter_test.dart';
import 'package:yahta/logic/habit/db.dart';
import 'package:yahta/logic/habit/view_models.dart';

void main() {
  group("Тестим вью-модели", () {
    test("Группировка привычек по дате", () async {
      var marks = [
        HabitMark(id: 1, habitId: 1, datetime: DateTime(2020, 3, 20)),
        HabitMark(id: 2, habitId: 1, datetime: DateTime(2020, 3, 20)),
        HabitMark(id: 3, habitId: 1, datetime: DateTime(2020, 3, 21)),
      ];

      var series = HabitMarkSeries(marks).series;
      expect(series, [
        HabitMarkFrequency(date: DateTime(2020, 3, 20), freq: 2),
        HabitMarkFrequency(date: DateTime(2020, 3, 21), freq: 1),
      ]);
    });
  });
}

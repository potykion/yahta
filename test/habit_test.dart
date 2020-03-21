import 'package:flutter_test/flutter_test.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:yahta/direction.dart';
import 'package:yahta/habit.dart';

void main() {
  Database db;

  setUp(() {
    db = Database(VmDatabase.memory());
  });
  tearDown(() async {
    await db.close();
  });

  group("Тестим привычки и работу с бд", () {
    test("Создание привычки & список привычек", () async {
      await db.insertHabit(HabitsCompanion(title: Value("Бегать")));

      var habits = await db.listHabits();
      expect(habits.length, 1);
      expect(habits[0].title, "Бегать");
    });

    test("Создание отметки привычки", () async {
      var todayDate = DayDateTimeRange(DateTime.now());
      var habitId =
          await db.insertHabit(HabitsCompanion(title: Value("Бегать")));

      var habitMarkId = await db
          .insertHabitMark(HabitMarksCompanion(habitId: Value(habitId)));
      var habit = await db.getHabitMarkById(habitMarkId);

      expect(habit.habitId, habitId);
      expect(todayDate.matchDatetime(habit.datetime), true);
    });

    test("Получение списка отметок за дату", () async {
      var habitId =
          await db.insertHabit(HabitsCompanion(title: Value("Бегать")));
      await db.insertHabitMark(HabitMarksCompanion(
          habitId: Value(habitId), datetime: Value(DateTime(2020, 3, 21))));
      await db.insertHabitMark(HabitMarksCompanion(
          habitId: Value(habitId), datetime: Value(DateTime(2020, 3, 20))));
      await db.insertHabitMark(HabitMarksCompanion(
          habitId: Value(habitId), datetime: Value(DateTime(2020, 3, 20))));

      var marks =
          await db.listHabitMarksForDate(DayDateTimeRange(DateTime(2020, 3, 20)));

      expect(marks.length, 2);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:tuple/tuple.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/db.dart';


void main() {
  Database _db;
  HabitRepo repo;

  setUp(() {
    _db = Database(VmDatabase.memory());
    repo = HabitRepo(_db);
  });
  tearDown(() async {
    await _db.close();
  });

  group("Тестим привычки и работу с бд", () {
    test("Создание привычки", () async {
      var habitId = await repo.insertHabit("Бегать");
      var habit = await repo.getHabitById(habitId);

      expect(habit.title, "Бегать");
      expect(habit.createdDate, isNotNull);
    });

    test("Список привычек", () async {
      await repo.insertHabit("Бегать");

      var habits = await repo.listHabits();

      expect(habits.length, 1);
    });

    test("Создание отметки привычки", () async {
      var todayDate = DayDateTimeRange(DateTime.now());
      var habitId = await repo.insertHabit("Бегать");

      var habitMarkId = await repo.insertHabitMark(habitId);
      var habit = await repo.getHabitMarkById(habitMarkId);

      expect(habit.habitId, habitId);
      expect(todayDate.matchDatetime(habit.datetime), true);
    });

    test("Получение списка отметок за дату", () async {
      var habitId = await repo.insertHabit("Бегать");
      await repo.insertHabitMark(habitId, DateTime(2020, 3, 21));
      await repo.insertHabitMark(habitId, DateTime(2020, 3, 20));
      await repo.insertHabitMark(habitId, DateTime(2020, 3, 20));

      var marks = await repo
          .listHabitMarksForDate(DayDateTimeRange(DateTime(2020, 3, 20)));

      expect(marks.length, 2);
    });

    test("Обновление привычки", () async {
      var habitId = await repo.insertHabit("Бегать");
      var habit = await repo.getHabitById(habitId);

      var updatedHabit = habit.copyWith(title: "Прыгать");
      await repo.updateHabit(updatedHabit);

      habit = await repo.getHabitById(habitId);
      expect(habit.title, "Прыгать");
    });

    test("Удаление привычки", () async {
      var habitId = await repo.insertHabit("Бегать");
      var habit = await repo.getHabitById(habitId);

      repo.deleteHabit(habit);

      habit = await repo.getHabitById(habitId);
      expect(habit, isNull);
    });

    test("Список отметок привычки", () async {
      var habitId = await repo.insertHabit("Бегать");
      await repo.insertHabitMark(habitId, DateTime(2020, 3, 21));
      await repo.insertHabitMark(habitId, DateTime(2020, 3, 20));
      await repo.insertHabitMark(habitId, DateTime(2020, 3, 20));

      var marks = await repo.listHabitMarks(habitId);

      expect(marks.length, 3);
    });

    test("Удаление отметки привычки", () async {
      var habitId = await repo.insertHabit("Бегать");
      var markId = await repo.insertHabitMark(habitId, DateTime(2020, 3, 21));
      var mark = await repo.getHabitMarkById(markId);

      repo.deleteHabitMark(mark);

      mark = await repo.getHabitMarkById(markId);
      expect(mark, isNull);
    });

    test("Получение последней даты отметки", () async {
      var habitId = await repo.insertHabit("Бегать");
      await repo.insertHabitMark(habitId, DateTime(2020, 3, 21));

      var tuples = await repo.getLatestHabitMarksBeforeToday(DateTime(2020, 3, 22));

      expect(tuples.first, Tuple2(habitId, DateTime(2020, 3, 21)));
    });
  });
}

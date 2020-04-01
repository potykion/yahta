import 'package:flutter_test/flutter_test.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/db.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/logic/habit/view_models.dart';

void main() {
  Database _db;
  HabitRepo repo;
  HabitState habitState;
  EditHabitState editHabitState;

  setUp(() {
    _db = Database(VmDatabase.memory());
    repo = HabitRepo(_db);
    habitState = HabitState(repo);
    editHabitState = EditHabitState(repo);
  });
  tearDown(() async {
    await _db.close();
  });

  group("Тестим стейт редактируемой привычки", () {
    test("Тестим загрузку привычки", () async {
      var habitId = await repo.insertHabit("title");

      await editHabitState.loadHabitToEdit(habitId);

      expect(editHabitState.habitToEdit.title, "title");
    });

    test("Тестим загрузку отметок привычки", () async {
      var habitId = await repo.insertHabit("title");
      await repo.insertHabitMark(habitId, DateTime(2020, 3, 30));
      await repo.insertHabitMark(habitId, DateTime(2020, 3, 31));

      await editHabitState.loadHabitToEdit(habitId);
      await editHabitState.loadWeeklyHabitMarks(WeekDateRange(DateTime(2020, 3, 30)));

      expect(editHabitState.habitMarks.length, 2);
    });

    test("Тестим обновление привычки", () async {
      var habitId = await repo.insertHabit("title");

      await editHabitState.loadHabitToEdit(habitId);
      await editHabitState.updateHabit(title: "new title");

      expect(editHabitState.habitToEdit.title, "new title");
      expect((await repo.getHabitById(habitId)).title, "new title");
    });

    test("Удаление привычки", () async {
      var habitId = await repo.insertHabit("title");

      await editHabitState.loadHabitToEdit(habitId);
      await editHabitState.deleteHabitToEdit();

      expect(editHabitState.habitToEdit, isNull);
      expect((await repo.getHabitById(habitId)), isNull);
    });

    test("Удаление отметки привычки", () async {
      var habitId = await repo.insertHabit("title");
      var habitMarkId = await repo.insertHabitMark(habitId, DateTime(2020, 3, 30));
      await editHabitState.loadHabitToEdit(habitId);
      await editHabitState.loadWeeklyHabitMarks(WeekDateRange(DateTime(2020, 3, 30)));

      var mark = await repo.getHabitMarkById(habitMarkId);
      await editHabitState.deleteHabitMark(mark);

      expect(editHabitState.habitMarks.length, 0);
      expect((await repo.getHabitMarkById(habitMarkId)), isNull);
    });
  });
}

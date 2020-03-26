import 'package:flutter_test/flutter_test.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:yahta/logic/habit/db.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/logic/habit/view_models.dart';

void main() {
  Database _db;
  HabitRepo _repo;
  HabitState habitState;

  setUp(() {
    _db = Database(VmDatabase.memory());
    _repo = HabitRepo(_db);
    habitState = HabitState(_repo);
  });
  tearDown(() async {
    await _db.close();
  });

  group("Тестим стейт", () {
    test("Тестим редактирование привычки", () async {
      var habitId = await _repo.insertHabit("title");
      var habit = await _repo.getHabitById(habitId);

      await _repo.insertHabitMark(habitId);
      await _repo.insertHabitMark(habitId);
      var habitMarks = await _repo.listHabitMarks(habitId);

      var vm = HabitViewModel(habit, habitMarks);
      await habitState.setHabitToEdit(vm);

      await habitState.updateHabitToEdit(title: "new title");

      habit = await _repo.getHabitById(habitId);
      expect(habit.title, "new title");
    });
  });
}

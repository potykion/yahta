import 'package:flutter_test/flutter_test.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
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

    test("Создание отметки привычки", () {});

    test("Получение списка отметок за дату", () {});
  });
}

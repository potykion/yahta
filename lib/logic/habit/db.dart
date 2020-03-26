import 'package:flutter/foundation.dart';
import 'package:moor/moor.dart';
import 'package:yahta/logic/core/view_models.dart';

part 'db.g.dart';

enum HabitType { positive, negative, neutral }

/// Собсно привычка
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  IntColumn get type => integer()
      .map(const HabitTypeConverter())
      .withDefault(Constant(HabitType.positive.index))();
}

/// Конвертит enum в int
/// https://moor.simonbinder.eu/docs/advanced-features/type_converters/
class HabitTypeConverter extends TypeConverter<HabitType, int> {
  const HabitTypeConverter();

  @override
  HabitType mapToDart(int fromDb) => HabitType.values[fromDb];

  @override
  int mapToSql(HabitType value) => value.index;
}

/// Отметка привычки (2020-03-19 в 23:17 привычка была зафиксирована)
class HabitMarks extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get habitId => integer()();

  DateTimeColumn get datetime => dateTime().withDefault(currentDateAndTime)();
}

@UseMoor(tables: [Habits, HabitMarks])
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  /// Мигрируем
  /// https://moor.simonbinder.eu/docs/advanced-features/migrations/
  @override
  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (Migrator m) => m.createAll(),
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.addColumn(habits, habits.type);
        }
      });

  Future<int> insertHabit(HabitsCompanion habitsCompanion) =>
      into(habits).insert(habitsCompanion);

  Future<List<Habit>> listHabits() => select(habits).get();

  Stream<List<Habit>> listHabitsStream() => select(habits).watch();

  Future<int> insertHabitMark(HabitMarksCompanion habitMarksCompanion) =>
      into(habitMarks).insert(habitMarksCompanion);

  Future<HabitMark> getHabitMarkById(int habitMarkId) =>
      (select(habitMarks)..where((mark) => mark.id.equals(habitMarkId)))
          .getSingle();

  Future<List<HabitMark>> listHabitMarksBetween(DateTime from, DateTime to) =>
      (select(habitMarks)
            ..where((mark) => mark.datetime.isBetweenValues(from, to)))
          .get();

  getHabitById(int habitId) =>
      (select(habits)..where((habit) => habit.id.equals(habitId))).getSingle();

  updateHabit(Habit updatedHabit) => update(habits).replace(updatedHabit);

  deleteHabitById(int habitId) =>
      (delete(habits)..where((habit) => habit.id.equals(habitId))).go();

  listHabitMarks(int habitId) => (select(habitMarks)
        ..where((mark) => mark.habitId.equals(habitId))
        ..orderBy([(mark) => OrderingTerm(expression: mark.datetime)]))
      .get();
}

class HabitRepo {
  Database db;

  HabitRepo(this.db);

  Future<int> insertHabit(String title) =>
      db.insertHabit(HabitsCompanion(title: Value(title)));

  Future<List<Habit>> listHabits() => db.listHabits();

  Future<int> insertHabitMark(int habitId, [DateTime dateTime]) =>
      db.insertHabitMark(
        HabitMarksCompanion(
          habitId: Value(habitId),
          datetime: dateTime == null ? Value.absent() : Value(dateTime),
        ),
      );

  Future<HabitMark> getHabitMarkById(int habitMarkId) =>
      db.getHabitMarkById(habitMarkId);

  Future<List<HabitMark>> listHabitMarksForDate(
          DayDateTimeRange dayDateTimeRange) =>
      db.listHabitMarksBetween(
          dayDateTimeRange.fromDateTime, dayDateTimeRange.toDateTime);

  Stream<List<Habit>> listHabitsStream() => db.listHabitsStream();

  Future<Habit> getHabitById(int habitId) => db.getHabitById(habitId);

  updateHabit(Habit updatedHabit) async => db.updateHabit(updatedHabit);

  deleteHabit(Habit habit) => db.deleteHabitById(habit.id);

  listHabitMarks(int habitId) => db.listHabitMarks(habitId);
}

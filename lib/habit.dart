import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:yahta/direction.dart';

part 'habit.g.dart';

/// Собсно привычка
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();
}

/// Отметка привычки (2020-03-19 в 23:17 привычка была зафиксирована)
class HabitMarks extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get habitId => integer()();

  DateTimeColumn get datetime => dateTime().withDefault(currentDateAndTime)();
}

QueryExecutor openConnection() {
  /// Copied from moor tutorial
  /// https://moor.simonbinder.eu/docs/getting-started/#generating-the-code

  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}

@UseMoor(tables: [Habits, HabitMarks])
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

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

  deleteHabitById(int habitId) => (delete(habits)..where((habit) => habit.id.equals(habitId))).go();
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
}

class HabitViewModel {
  Habit habit;
  List<HabitMark> habitMarks;

  HabitViewModel(this.habit, this.habitMarks);
}

class HabitState extends ChangeNotifier {
  bool loading = false;
  var currentDate = DateTime.now();
  List<HabitViewModel> habitVMs = [];
  HabitViewModel habitToEdit;

  HabitRepo habitRepo;

  HabitState(this.habitRepo);

  setHabitToEdit(HabitViewModel habitViewModel){
    habitToEdit = habitViewModel;
    notifyListeners();
  }

  loadDateHabits() async {
    loading = true;
    notifyListeners();

    var habits = await habitRepo.listHabits();
    var habitMarks =
        await habitRepo.listHabitMarksForDate(DayDateTimeRange(currentDate));

    habitVMs = habits
        .map(
          (habit) => HabitViewModel(
            habit,
            habitMarks.where((mark) => mark.habitId == habit.id).toList(),
          ),
        )
        .toList();

    loading = false;
    notifyListeners();
  }

  createHabit(String title) async {
    var habitId = await habitRepo.insertHabit(title);

    var habit = await habitRepo.getHabitById(habitId);
    habitVMs.add(HabitViewModel(habit, []));

    notifyListeners();
  }

  createHabitMark(int habitId) async {
    var habitMarkId = await habitRepo.insertHabitMark(habitId, currentDate);

    var habitMark = await habitRepo.getHabitMarkById(habitMarkId);
    var vm = habitVMs.singleWhere((vm) => vm.habit.id == habitId);
    vm.habitMarks.add(habitMark);

    notifyListeners();
  }

  swipeDate(SwipeDirection swipeDirection) {
    currentDate = DateTimeSwipe(currentDate, swipeDirection).swipedDatetime;

    notifyListeners();
  }

  updateHabitToEdit({String title}) async {
    habitToEdit.habit = habitToEdit.habit.copyWith(title: title);
    await habitRepo.updateHabit(habitToEdit.habit);
  }

  deleteHabitToEdit() async {
    await habitRepo.deleteHabit(habitToEdit.habit);

    habitVMs.remove(habitToEdit);
    notifyListeners();
  }
}

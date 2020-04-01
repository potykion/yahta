import 'package:flutter/cupertino.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/view_models.dart';

import 'db.dart';

class EditHabitState extends ChangeNotifier {
  // Редактируемая привычка; редактируются обычно название, тип
  Habit habitToEdit;

  // Список отметок привычки - используется для частотного графика
  //   Может быть отредактирован: удаление и редактирование отетки за день
  List<HabitMark> habitMarks;

  HabitRepo _habitRepo;

  EditHabitState(this._habitRepo);

  loadHabitToEdit(int habitId) async {
    this.habitToEdit = await _habitRepo.getHabitById(habitId);
    notifyListeners();
  }

  loadWeeklyHabitMarks(WeekDateRange weekDateRange) async {
    assert(this.habitToEdit != null);
    this.habitMarks = await _habitRepo.listHabitMarksBetween(
      weekDateRange.fromDateTime,
      weekDateRange.toDateTime,
      this.habitToEdit.id,
    );
    notifyListeners();
  }

  updateHabit({String title, HabitType habitType}) async {
    habitToEdit = habitToEdit.copyWith(title: title, type: habitType);
    await _habitRepo.updateHabit(habitToEdit);
    notifyListeners();
  }

  deleteHabitToEdit() async {
    await _habitRepo.deleteHabit(habitToEdit);
    habitToEdit = null;
    notifyListeners();
  }
}

// todo split to ListHabitState & EditHabitState
class HabitState extends ChangeNotifier {
  /// Флаг загрузки списка привычек
  bool loading = false;

  /// Текущая дата, используется для фильтра отметок привычек за день
  /// Используется в основном в списке привычек
  /// todo Мб имеет смысл туда его перенести
  var currentDate = DateTime.now();

  /// Список привычек и отметок за день
  List<HabitViewModel> habitVMs = [];

  /// Редактируемая привычка
  HabitViewModel habitToEdit;

  /// Дата, по которой фильтруются отметки редактируемой привычки
  DateTime habitMarkStatsDate;

  /// Абстракция над бд
  HabitRepo habitRepo;

  HabitState(this.habitRepo);

  setCurrentDate(DateTime dateTime) {
    this.currentDate = dateTime;
    notifyListeners();
  }

  setHabitMarkStatsDate(DateTime dateTime) {
    habitMarkStatsDate = dateTime;
    notifyListeners();
  }

  setHabitToEdit(HabitViewModel habitViewModel) async {
    var currentWeekDateRange = WeekDateRange(this.currentDate);

    habitToEdit = HabitViewModel(
        habitViewModel.habit,
        await habitRepo.listHabitMarksBetween(
          currentWeekDateRange.fromDateTime,
          currentWeekDateRange.toDateTime,
          habitViewModel.habit.id,
        ));

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

  createHabitMark(int habitId) async {
    var habitMarkId = await habitRepo.insertHabitMark(habitId, currentDate);

    var habitMark = await habitRepo.getHabitMarkById(habitMarkId);
    var vm = habitVMs.singleWhere((vm) => vm.habit.id == habitId);
    vm.habitMarks.add(habitMark);

    notifyListeners();
  }

  createHabit(String title) async {
    var habitId = await habitRepo.insertHabit(title);

    var habit = await habitRepo.getHabitById(habitId);
    habitVMs.add(HabitViewModel(habit, []));

    notifyListeners();
  }

  updateHabitToEdit({String title, HabitType habitType}) async {
    habitToEdit.habit =
        habitToEdit.habit.copyWith(title: title, type: habitType);
    await habitRepo.updateHabit(habitToEdit.habit);
    notifyListeners();
  }

  deleteHabitToEdit() async {
    await habitRepo.deleteHabit(habitToEdit.habit);

    habitVMs.remove(habitToEdit);
    notifyListeners();
  }

  loadWeeklyHabits(WeekDateRange weekDateRange) async {
    habitToEdit.habitMarks = await habitRepo.listHabitMarksBetween(
      weekDateRange.fromDateTime,
      weekDateRange.toDateTime,
      habitToEdit.habit.id,
    );
    notifyListeners();
  }

  deleteHabitMark(HabitMark mark) async {
    await habitRepo.deleteHabitMark(mark);

    habitToEdit.habitMarks.remove(mark);
    notifyListeners();
  }

  updateHabitMark(HabitMark mark, {DateTime datetime}) async {
    var updatedMark = mark.copyWith(datetime: datetime);

    await habitRepo.updateHabitMark(updatedMark);

    habitToEdit.habitMarks =
        habitToEdit.habitMarks.where((m) => m.id != mark.id).toList() +
            [updatedMark];
    notifyListeners();
  }
}

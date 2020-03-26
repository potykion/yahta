import 'package:flutter/cupertino.dart';
import 'package:yahta/logic/core/view_models.dart';
import 'package:yahta/logic/habit/view_models.dart';

import 'db.dart';

class HabitState extends ChangeNotifier {
  bool loading = false;
  var currentDate = DateTime.now();
  List<HabitViewModel> habitVMs = [];
  HabitViewModel habitToEdit;

  HabitRepo habitRepo;

  HabitState(this.habitRepo);

  setHabitToEdit(HabitViewModel habitViewModel) async {
    var currentWeekDateRange = WeekDateRange(this.currentDate);

    habitToEdit = HabitViewModel(
        habitViewModel.habit,
        await habitRepo.listHabitMarksBetween(
          currentWeekDateRange.fromDateTime,
          currentWeekDateRange.toDateTime,
          habitViewModel.habit.id,
        )
    );

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
}

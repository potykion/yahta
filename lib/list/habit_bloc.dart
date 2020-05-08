import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:yahta/list/view_models.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/db.dart';

import 'models.dart';

////////////////////////////////////////////////////////////////////////////////
// STATE
////////////////////////////////////////////////////////////////////////////////

class HabitState {
  List<Habit> habits;
  List<HabitMark> habitMarks;
  DateRelation selectedDateRelation;

  HabitState({habits, habitMarks, selectedDateRelation})
      : this.habits = habits ?? [],
        this.habitMarks = habitMarks ?? [],
        this.selectedDateRelation = selectedDateRelation ?? DateRelation.today;

  Map<DateRelation, CompletionStatus> get dateRelationCompletions =>
      Map.fromEntries(OrderedDateRelations.map((dr) {
        var viewModels = filterHabitViewModelsByDateRange(
          DayDateTimeRange(DateTime.now().add(DateRelationToDuration[dr])),
        );

        var completionStatus = viewModels.every((vm) => vm.completed)
            ? CompletionStatus.positive
            : viewModels.every((vm) => !vm.completed)
                ? CompletionStatus.negative
                : CompletionStatus.neutral;

        return MapEntry(dr, completionStatus);
      }));

  Color get selectedDateRelationColor =>
      StatusToColorMap[dateRelationCompletions[selectedDateRelation]];

  Map<DateRelation, Color> get appBarColors => dateRelationCompletions.map(
        (dr, completionStatus) =>
            MapEntry(dr, StatusToColorMap[completionStatus]),
      );

  DayDateTimeRange get dateRelationDateRange => DayDateTimeRange(
        DateTime.now().add(DateRelationToDuration[selectedDateRelation]),
      );

  List<HabitViewModel> get habitViewModels => habits
      .where((h) => h.stoppedDate == null)
      .map((h) => HabitViewModel(
            habit: h,
            habitMarks: habitMarks.where((hm) => hm.habitId == h.id).toList(),
          ))
      .toList();

  List<HabitViewModel> get dateRelationHabitViewModels =>
      filterHabitViewModelsByDateRange(dateRelationDateRange);

  List<HabitViewModel> filterHabitViewModelsByDateRange(
          DayDateTimeRange dateRange) =>
      habitViewModels
          .map(
            (vm) => HabitViewModel(
              habit: vm.habit,
              habitMarks: vm.habitMarks
                  .where((hm) => dateRange.matchDatetime(hm.datetime))
                  .toList(),
            ),
          )
          .toList();
}

////////////////////////////////////////////////////////////////////////////////
// EVENTS
////////////////////////////////////////////////////////////////////////////////

class HabitEvent {}

class HabitsLoadedEvent extends HabitEvent {}

class HabitCompletedEvent extends HabitEvent {
  int id;

  HabitCompletedEvent(this.id);
}

class HabitIncompletedEvent extends HabitEvent {
  int id;

  HabitIncompletedEvent(this.id);
}

class DateRelationChangedEvent extends HabitEvent {
  DateRelation dateRelation;

  DateRelationChangedEvent(this.dateRelation);
}

class HabitCreatedEvent extends HabitEvent {
  String habitTitle;

  HabitCreatedEvent(this.habitTitle);
}

class HabitUpdatedEvent extends HabitEvent {
  int id;
  String title;
  DateTime stoppedDate;

  HabitUpdatedEvent(this.id, {this.title, this.stoppedDate});
}

////////////////////////////////////////////////////////////////////////////////
// BLOC
////////////////////////////////////////////////////////////////////////////////

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  HabitRepo habitRepo;

  HabitBloc(this.habitRepo) : super();

  @override
  HabitState get initialState => HabitState();

  @override
  Stream<HabitState> mapEventToState(HabitEvent event) async* {
    if (event is HabitsLoadedEvent) {
      var habits = await habitRepo.listHabits();
      var habitMarks = await habitRepo.listHabitMarksBetween(
        DayDateTimeRange(
          DateTime.now().add(DateRelationToDuration[DateRelation.twoDaysAgo]),
        ).fromDateTime,
        DateTime.now(),
      );

      yield HabitState(
        habits: habits,
        habitMarks: habitMarks,
        selectedDateRelation: state.selectedDateRelation,
      );
    } else if (event is DateRelationChangedEvent) {
      yield HabitState(
        habits: state.habits,
        habitMarks: state.habitMarks,
        selectedDateRelation: event.dateRelation,
      );
    } else if (event is HabitCompletedEvent) {
      var markId = await habitRepo.insertHabitMark(
        event.id,
        DateTime.now().add(DateRelationToDuration[state.selectedDateRelation]),
      );
      var mark = await habitRepo.getHabitMarkById(markId);
      yield HabitState(
        habits: state.habits,
        habitMarks: state.habitMarks..add(mark),
        selectedDateRelation: state.selectedDateRelation,
      );
    } else if (event is HabitIncompletedEvent) {
      var marksToRemove = state.habitMarks
          .where((hm) => hm.habitId == event.id)
          .where(
              (hm) => state.dateRelationDateRange.matchDatetime(hm.datetime));
      await Future.wait(
        marksToRemove.map((hm) => habitRepo.deleteHabitMark((hm))),
      );

      var newHabitMarks =
          state.habitMarks.where((hm) => !marksToRemove.contains(hm)).toList();

      yield HabitState(
        habits: state.habits,
        habitMarks: newHabitMarks,
        selectedDateRelation: state.selectedDateRelation,
      );
    } else if (event is HabitCreatedEvent) {
      var habitId = await habitRepo.insertHabit(event.habitTitle);
      var habit = await habitRepo.getHabitById(habitId);
      yield HabitState(
        habits: state.habits..add(habit),
        habitMarks: state.habitMarks,
        selectedDateRelation: state.selectedDateRelation,
      );
    } else if (event is HabitUpdatedEvent) {
      var habit = await habitRepo.getHabitById(event.id);
      var updatedHabit = habit.copyWith(
        title: event.title ?? habit.title,
        stoppedDate: event.stoppedDate ?? habit.stoppedDate,
      );

      await habitRepo.updateHabit(updatedHabit);

      var newHabits =
          state.habits.where((h) => h.id != updatedHabit.id).toList() +
              [updatedHabit];

      yield HabitState(
        habits: newHabits,
        habitMarks: state.habitMarks,
        selectedDateRelation: state.selectedDateRelation,
      );
    }
  }
}

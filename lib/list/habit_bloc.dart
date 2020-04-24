import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:yahta/list/smth.dart';
import 'package:yahta/list/widgets.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/db.dart';

////////////////////////////////////////////////////////////////////////////////
// MODELS AND MAPPINGS
////////////////////////////////////////////////////////////////////////////////

enum DateRelation { today, yesterday, twoDaysAgo }

List<DateRelation> OrderedDateRelations = [
  DateRelation.twoDaysAgo,
  DateRelation.yesterday,
  DateRelation.today,
];

Map<DateRelation, Duration> DateRelationToDuration = {
  DateRelation.today: Duration(days: 0),
  DateRelation.yesterday: Duration(days: -1),
  DateRelation.twoDaysAgo: Duration(days: -2),
};

Map<int, DateRelation> SwiperIndexToDateRelation = {
  0: DateRelation.twoDaysAgo,
  1: DateRelation.yesterday,
  2: DateRelation.today,
};

Map<DateRelation, int> DateRelationToSwiperIndex = {
  DateRelation.twoDaysAgo: 0,
  DateRelation.yesterday: 1,
  DateRelation.today: 2,
};

class HabitViewModel {
  Habit habit;
  List<HabitMark> habitMarks;

  HabitViewModel({this.habit, this.habitMarks});

  int get id => habit.id;

  String get title => habit.title;

  bool get completed => this.habitMarks.length > 0;

  CompletionStatus get completionStatus =>
      completed ? CompletionStatus.positive : CompletionStatus.negative;
}

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

  Map<DateRelation, String> get appBarTitles => {
        DateRelation.twoDaysAgo: "Итоги за\nпозавчера",
        DateRelation.yesterday: "Итоги за\nвчера",
        DateRelation.today: "Расписание\nна сегодня"
      };

  Map<DateRelation, Color> get appBarColors => Map.fromEntries(
        OrderedDateRelations.map(
          (dr) => MapEntry(
            dr,
            StatusToColorMap[computeDateRelationCompletionStatus(
              this.habits,
              this.habitMarks,
              dr,
            )],
          ),
        ),
      );

  DayDateTimeRange get dateRelationDateRange => DayDateTimeRange(
        DateTime.now().add(DateRelationToDuration[selectedDateRelation]),
      );

  List<HabitViewModel> get habitViewModels => habits
      .map(
        (h) => HabitViewModel(
          habit: h,
          habitMarks: habitMarks
              .where((hm) => hm.habitId == h.id)
              .where((hm) => dateRelationDateRange.matchDatetime(hm.datetime))
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
        DayDateTimeRange(DateTime.now()
                .add(DateRelationToDuration[DateRelation.twoDaysAgo]))
            .fromDateTime,
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
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:yahta/list/smth.dart';
import 'package:yahta/list/widgets.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/db.dart';

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

class DateRelationHabitViewModel {
  DateRelation dateRelation;
  List<HabitViewModel> habits;
}

class HabitViewModel {
  int id;
  String title;
  bool completed;

  HabitViewModel({this.id, this.title, this.completed = false});
}

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

//  todo: pizda
  Map<DateRelation, List<HabitViewModel>> get dateRelationHabitViewModels {
    var map = Map.fromEntries(
      [DateRelation.today, DateRelation.yesterday, DateRelation.twoDaysAgo].map(
        (dr) {
          var drDateRange =
              DayDateTimeRange(DateTime.now().add(DateRelationToDuration[dr]));

          return MapEntry(
            dr,
            this.habits.map(
              (h) {
                var completed = this
                        .habitMarks
                        .where((hm) => hm.habitId == h.id)
                        .where((hm) => drDateRange.matchDatetime(hm.datetime))
                        .length >
                    0;

                return HabitViewModel(
                  id: h.id,
                  title: h.title,
                  completed: completed,
                );
              },
            ),
          );
        },
      ),
    );

    return map;
  }

  Map<DateRelation, bool> get dateRelationHabitCompletions => {
        DateRelation.today: dateRelationHabitViewModels[DateRelation.today]
            .every((vm) => vm.completed),
        DateRelation.yesterday:
            dateRelationHabitViewModels[DateRelation.yesterday]
                .every((vm) => vm.completed),
        DateRelation.twoDaysAgo:
            dateRelationHabitViewModels[DateRelation.twoDaysAgo]
                .every((vm) => vm.completed),
      };
}

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
        DateTime.now().add(DateRelationToDuration[DateRelation.twoDaysAgo]),
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
      var markId = await habitRepo.insertHabitMark(event.id);
      var mark = await habitRepo.getHabitMarkById(markId);
      yield HabitState(
        habits: state.habits,
        habitMarks: state.habitMarks..add(mark),
      );
    } else if (event is HabitIncompletedEvent) {
      yield state;
//      var habitToIncomplete = state.habits.firstWhere((h) => h.id == event.id);
//      habitToIncomplete.completed = false;
//
//      var newHabits = state.habits.where((h) => h.id != event.id).toList();
//      newHabits.add(habitToIncomplete);
//
//      yield HabitState(habits: newHabits);
    }
  }
}

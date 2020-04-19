import 'package:bloc/bloc.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/db.dart';

enum DateRelation { today, yesterday, twoDaysAgo }

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

class HabitViewModel {
  int id;
  String title;
  bool completed;

  HabitViewModel({this.id, this.title, this.completed = false});
}

class HabitState {
  List<Habit> habits;
  List<HabitMark> habitMarks;

  HabitState({habits, habitMarks})
      : this.habits = habits ?? [],
        this.habitMarks = habitMarks ?? [];

  Map<DateRelation, List<HabitViewModel>> get dateRelationHabitViewModels {

    var todayDateTimeRange = DayDateTimeRange(DateTime.now());
    var todayHabitMarks = this.habitMarks.where((hm) => todayDateTimeRange.matchDatetime(hm.datetime));
    print(DayDateTimeRange(DateTime.now()));

    var map = {
      DateRelation.today: this.habits.map(
            (h) => HabitViewModel(
            id: h.id,
            title: h.title,
            completed: todayHabitMarks.where((hm) => hm.habitId == h.id).length > 0),
      ).toList(),
      DateRelation.yesterday: this.habits.map(
            (h) => HabitViewModel(
            id: h.id,
            title: h.title,
            completed: this
                .habitMarks
                .where((hm) =>
            hm.id == h.id &&
                DayDateTimeRange(DateTime.now()
                    .subtract(Duration(days: 1)))
                    .matchDatetime(hm.datetime))
                .length >
                0),
      ).toList(),
      DateRelation.twoDaysAgo: this.habits.map(
            (h) => HabitViewModel(
            id: h.id,
            title: h.title,
            completed: this
                .habitMarks
                .where((hm) =>
            hm.id == h.id &&
                DayDateTimeRange(DateTime.now()
                    .subtract(Duration(days: 2)))
                    .matchDatetime(hm.datetime))
                .length >
                0),
      ).toList(),
    };

    return map;
  }

  Map<DateRelation, bool> get dateRelationHabitCompletions => {
    DateRelation.today: dateRelationHabitViewModels[DateRelation.today].every((vm) => vm.completed),
    DateRelation.yesterday: dateRelationHabitViewModels[DateRelation.yesterday].every((vm) => vm.completed),
    DateRelation.twoDaysAgo: dateRelationHabitViewModels[DateRelation.twoDaysAgo].every((vm) => vm.completed),
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
          DateTime.now().subtract(Duration(days: 2)), DateTime.now());

      yield HabitState(habits: habits, habitMarks: habitMarks);
      print("done");
    } else if (event is HabitCompletedEvent) {
      var markId = await habitRepo.insertHabitMark(event.id);
      var mark = await habitRepo.getHabitMarkById(markId);
      var newState = HabitState(habits: state.habits, habitMarks: state.habitMarks..add(mark));
      yield newState;
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

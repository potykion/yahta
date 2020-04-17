import 'package:bloc/bloc.dart';

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
  List<HabitViewModel> habits;
  DateRelation dateRelation;

  HabitState({habits, this.dateRelation = DateRelation.today}) :
        this.habits = habits ?? [];

  List<HabitViewModel> get habitsSorted =>
      habits..sort((h1, h2) => h1.id.compareTo(h2.id));

  bool get habitsCompleted => habits.every((h) => h.completed);

  String get dateRelationToStr => {
    DateRelation.twoDaysAgo: "Итоги за\nпозавчера",
    DateRelation.yesterday: "Итоги за\nвчера",
    DateRelation.today: "Расписание\nна сегодня",
  }[this.dateRelation].toUpperCase();
}

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  @override
  HabitState get initialState => HabitState();

  @override
  Stream<HabitState> mapEventToState(HabitEvent event) async* {
    if (event is HabitsLoadedEvent) {
      yield HabitState(habits: [
        HabitViewModel(id: 1, title: "Рисовать"),
        HabitViewModel(id: 2, title: "Читать"),
        HabitViewModel(id: 3, title: "Пилить трекер"),
      ]);
    } else if (event is HabitCompletedEvent) {
      var habitToComplete = state.habits.firstWhere((h) => h.id == event.id);
      habitToComplete.completed = true;

      var newHabits = state.habits.where((h) => h.id != event.id).toList();
      newHabits.add(habitToComplete);

      yield HabitState(habits: newHabits);
    } else if (event is HabitIncompletedEvent) {
      var habitToIncomplete = state.habits.firstWhere((h) => h.id == event.id);
      habitToIncomplete.completed = false;

      var newHabits = state.habits.where((h) => h.id != event.id).toList();
      newHabits.add(habitToIncomplete);

      yield HabitState(habits: newHabits);
    } else if (event is DateRelationChangedEvent) {
      yield HabitState(habits: state.habits, dateRelation: event.dateRelation);
    }
  }
}

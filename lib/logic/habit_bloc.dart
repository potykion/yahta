import 'package:bloc/bloc.dart';

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

class HabitViewModel {
  int id;
  String title;
  bool completed;

  HabitViewModel({this.id, this.title, this.completed = false});
}

class HabitState {
  List<HabitViewModel> habits;

  HabitState([this.habits = const []]);

  List<HabitViewModel> get habitsSorted => habits..sort((h1, h2) => h1.id.compareTo(h2.id));
  bool get habitsCompleted => habits.every((h) => h.completed);
}

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  @override
  HabitState get initialState => HabitState();

  @override
  Stream<HabitState> mapEventToState(HabitEvent event) async* {
    if (event is HabitsLoadedEvent) {
      yield HabitState([
        HabitViewModel(id: 1, title: "Рисовать"),
        HabitViewModel(id: 2, title: "Читать"),
        HabitViewModel(id: 3, title: "Пилить трекер"),
      ]);
    } else if (event is HabitCompletedEvent) {
      var habitToComplete = state.habits.firstWhere((h) => h.id == event.id);
      habitToComplete.completed = true;

      var newHabits = state.habits.where((h) => h.id != event.id).toList();
      newHabits.add(habitToComplete);

      yield HabitState(newHabits);
    } else if (event is HabitIncompletedEvent) {
      var habitToIncomplete = state.habits.firstWhere((h) => h.id == event.id);
      habitToIncomplete.completed = false;

      var newHabits = state.habits.where((h) => h.id != event.id).toList();
      newHabits.add(habitToIncomplete);

      yield HabitState(newHabits);
    }
  }
}

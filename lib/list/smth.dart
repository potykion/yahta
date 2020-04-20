import 'package:yahta/list/habit_bloc.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/db.dart';

enum DateStatus { positive, neutral, negative }

computeDateRelationCompletionStatus(
  List<Habit> habits,
  List<HabitMark> habitMarks,
  DateRelation dateRelation,
) {
  var allHabitIds = uniqueHabitIds(habits: habits);
  var completedHabitIds = uniqueHabitIds(
    habitMarks: filterDateRelationHabitMarks(habitMarks, dateRelation),
  );

  if (allHabitIds == completedHabitIds) {
    return DateStatus.positive;
  }
  if (completedHabitIds.length == 0) {
    return DateStatus.negative;
  }
  return DateStatus.neutral;
}

uniqueHabitIds({List<Habit> habits, List<HabitMark> habitMarks}) {
  return ((habits ?? []).map((h) => h.id).toList() +
          (habitMarks ?? []).map((h) => h.habitId).toList())
      .toSet();
}

List<HabitMark> filterDateRelationHabitMarks(
        List<HabitMark> habitMarks, DateRelation dateRelation) =>
    habitMarks
        .where((hm) =>
            dateRelationToDateRange(dateRelation).matchDatetime(hm.datetime))
        .toList();

DayDateTimeRange dateRelationToDateRange(DateRelation dateRelation) =>
    DayDateTimeRange(DateTime.now().add(dateRelationToDuration(dateRelation)));

Duration dateRelationToDuration(DateRelation dateRelation) {
  switch (dateRelation) {
    case DateRelation.today:
      return Duration(days: 0);
    case DateRelation.yesterday:
      return Duration(days: -1);
    case DateRelation.twoDaysAgo:
      return Duration(days: -2);
    default:
      throw ArgumentError("wtf: $dateRelation");
  }
}

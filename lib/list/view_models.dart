import 'package:flutter/material.dart';
import 'package:yahta/logic/habit/db.dart';

import 'models.dart';

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

Map<DateRelation, String> get AppBarTitles => {
      DateRelation.twoDaysAgo: "Итоги за\nпозавчера",
      DateRelation.yesterday: "Итоги за\nвчера",
      DateRelation.today: "Расписание\nна сегодня"
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

Map<CompletionStatus, Color> StatusToColorMap = {
  CompletionStatus.positive: Color(0xff95E1D3),
  CompletionStatus.neutral: Color(0xffFCE38A),
  CompletionStatus.negative: Color(0xffF88181),
};

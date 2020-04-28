import 'package:flutter/material.dart';

enum CompletionStatus { positive, neutral, negative }

Map<CompletionStatus, Color> StatusToColorMap = {
  CompletionStatus.positive: Color(0xff95E1D3),
  CompletionStatus.neutral: Color(0xffFCE38A),
  CompletionStatus.negative: Color(0xffF88181),
};

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

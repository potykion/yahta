import 'package:intl/intl.dart';

class DateTimeStart {
  DateTime initial;

  DateTimeStart(this.initial);

  get dateTime => DateTime(initial.year, initial.month, initial.day);
}

class DateTimeEnd {
  DateTime initial;

  DateTimeEnd(this.initial);

  get dateTime =>
      DateTime(initial.year, initial.month, initial.day, 23, 59, 59);
}

/// Дейтренжи дня (например, 2020-03-19 00:00:00 - 2020-03-19 23:59:59)
class DayDateTimeRange {
  DateTime initialDateTime;

  DayDateTimeRange([initialDateTime])
      : this.initialDateTime = initialDateTime ?? DateTime.now();

  DateTime get fromDateTime => DateTimeStart(initialDateTime).dateTime;

  DateTime get toDateTime => DateTimeEnd(initialDateTime).dateTime;

  matchDatetime(DateTime dateTime) =>
      dateTime.isAfter(fromDateTime) && dateTime.isBefore(toDateTime) ||
      dateTime.isAtSameMomentAs(fromDateTime) ||
      dateTime.isAtSameMomentAs(toDateTime);

  @override
  String toString() => DateFormat("yyyy-MM-dd").format(fromDateTime);
}

/// Дейтренж недели (2020-03-22 00:00:00 - 2020-03-29 23:59:59)
class WeekDateRange {
  DateTime initial;

  WeekDateRange(this.initial);

  DateTime get fromDateTime =>
      DateTimeStart(initial.add(Duration(days: -initial.weekday + 1))).dateTime;

  DateTime get toDateTime =>
      DateTimeEnd(initial.add(Duration(days: -initial.weekday + 1 + 6)))
          .dateTime;

  WeekDateRange get nextWeekDateRange =>
      WeekDateRange(toDateTime.add(Duration(days: 1)));

  WeekDateRange get previousWeekDateRange =>
      WeekDateRange(fromDateTime.add(Duration(days: -1)));

  List<DateTime> get dates =>
      List.generate(7, (days) => this.fromDateTime.add(Duration(days: days)));

  @override
  String toString() {
    var fromStr = DateFormat("yyyy-MM-dd").format(fromDateTime);
    var toStr = DateFormat("yyyy-MM-dd").format(toDateTime);
    return "$fromStr - $toStr";
  }
}

class DateTimeCompare {
  DateTime dateTime1;
  DateTime dateTime2;

  DateTimeCompare(this.dateTime1, this.dateTime2);

  DateTime get min {
    return this.dateTime1.isAfter(this.dateTime2)
        ? this.dateTime2
        : this.dateTime1;
  }

  DateTime get max {
    return this.dateTime1.isAfter(this.dateTime2)
        ? this.dateTime1
        : this.dateTime2;
  }
}

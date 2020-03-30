import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/core/swipe.dart';

typedef Builder = Widget Function(BuildContext context);
typedef OnDaySwipe = void Function(DateTime dateTime);
typedef OnWeekChange = void Function(WeekDateRange weekDateRange);

class DaySwiper extends StatefulWidget {
  final Builder builder;
  final OnDaySwipe onDaySwipe;
  final DateTime currentDate;

  DaySwiper({@required this.builder, @required this.onDaySwipe, currentDate})
      : currentDate = currentDate ?? DateTime.now();

  @override
  _DaySwiperState createState() => _DaySwiperState();
}

class _DaySwiperState extends State<DaySwiper> {
  DateTime currentDate;
  var previousIndex = 0;

  @override
  void initState() {
    super.initState();
    currentDate = widget.currentDate;
  }

  @override
  Widget build(BuildContext context) => Swiper(
        itemBuilder: (context, _) => widget.builder(context),
        onIndexChanged: (int newIndex) {
          setState(() {
            currentDate = DateTimeSwipe(
              currentDate,
              SwipeDirection(previousIndex, newIndex),
            ).swipedDatetime;
            previousIndex = newIndex;
          });

          widget.onDaySwipe(currentDate);
        },
        itemCount: 3,
      );
}

class WeekSwiper extends StatefulWidget {
  final WeekDateRange weekDateRange;
  final Builder builder;
  final OnWeekChange onWeekChange;

  WeekSwiper({
    @required this.builder,
    @required this.onWeekChange,
    weekDateRange,
  }) : weekDateRange = weekDateRange ?? WeekDateRange(DateTime.now());

  @override
  _WeekSwiperState createState() => _WeekSwiperState();
}

class _WeekSwiperState extends State<WeekSwiper> {
  int previousIndex = 0;
  WeekDateRange currentWeekDateRange;

  @override
  void initState() {
    super.initState();
    currentWeekDateRange = widget.weekDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemBuilder: (context, __) => widget.builder(context),
      itemCount: 3,
      onIndexChanged: (int newIndex) async {
        var swipeDirection = SwipeDirection(previousIndex, newIndex);

        setState(() {
          currentWeekDateRange = swipeDirection.type == SwipeDirection.LEFT_TYPE
              ? currentWeekDateRange.nextWeekDateRange
              : currentWeekDateRange.previousWeekDateRange;
          previousIndex = newIndex;
        });

        widget.onWeekChange(currentWeekDateRange);
      },
    );
  }
}

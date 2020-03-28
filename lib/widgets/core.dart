import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:yahta/logic/core/swipe.dart';

typedef Builder = Widget Function(BuildContext context);
typedef OnDaySwipe = void Function(DateTime dateTime);

class DaySwiper extends StatefulWidget {
  final Builder builder;
  final OnDaySwipe onDaySwipe;
  final DateTime currentDate;

  DaySwiper(
      {@required this.builder, @required this.onDaySwipe, currentDate})
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

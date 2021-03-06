/// Направление свайпа
class SwipeDirection {
  // 0 1 2 > 2 0 1
  static const RIGHT_TYPE = "right";

  // 0 1 2 > 1 2 0
  static const LEFT_TYPE = "left";

  int fromIndex;
  int toIndex;

  SwipeDirection(int fromIndex, int toIndex) {
    assert(fromIndex >= 0 && fromIndex <= 2);
    assert(toIndex >= 0 && toIndex <= 2);

    this.fromIndex = fromIndex;
    this.toIndex = toIndex;
  }

  factory SwipeDirection.right() => SwipeDirection(0, 2);

  factory SwipeDirection.left() => SwipeDirection(2, 0);

  String get type {
    if (fromIndex == 0 && toIndex == 2 ||
        fromIndex == 2 && toIndex == 1 ||
        fromIndex == 1 && toIndex == 0) {
      return RIGHT_TYPE;
    } else {
      return LEFT_TYPE;
    }
  }
}

/// Свайпнутая дата
class DateTimeSwipe {
  DateTime currentDate;
  SwipeDirection swipeDirection;

  DateTimeSwipe(this.currentDate, this.swipeDirection);

  get swipedDatetime => currentDate.add(
      Duration(days: swipeDirection.type == SwipeDirection.LEFT_TYPE ? 1 : -1));
}



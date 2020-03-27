import 'package:flutter_test/flutter_test.dart';
import 'package:yahta/logic/core/swipe.dart';

void main() {
  group("Пакет swipe.dart", () {
    test("Определение направления свайпа", () {
      expect(SwipeDirection(0, 2).type, SwipeDirection.RIGHT_TYPE);
      expect(SwipeDirection(2, 1).type, SwipeDirection.RIGHT_TYPE);
      expect(SwipeDirection(1, 0).type, SwipeDirection.RIGHT_TYPE);
      expect(SwipeDirection(0, 1).type, SwipeDirection.LEFT_TYPE);
      expect(SwipeDirection(1, 2).type, SwipeDirection.LEFT_TYPE);
      expect(SwipeDirection(2, 0).type, SwipeDirection.LEFT_TYPE);

      expect(SwipeDirection.right().type, SwipeDirection.RIGHT_TYPE);
      expect(SwipeDirection.left().type, SwipeDirection.LEFT_TYPE);

      expect(() => SwipeDirection(3, 0), throwsAssertionError);
      expect(() => SwipeDirection(0, 3), throwsAssertionError);
    });

    test("Свайп даты", () {
      var dateTime = DateTime(2020, 3, 19);

      expect(DateTimeSwipe(dateTime, SwipeDirection.right()).swipedDatetime,
          DateTime(2020, 3, 18));
      expect(DateTimeSwipe(dateTime, SwipeDirection.left()).swipedDatetime,
          DateTime(2020, 3, 20));
    });
  });
}

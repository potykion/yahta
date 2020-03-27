import 'package:flutter_test/flutter_test.dart';
import 'package:yahta/logic/core/date.dart';

main() {
  group("Тестирование date.dart", () {
    test("Дейтренжи дня", () {
      var dateTime = DateTime(2020, 3, 19, 23, 2);
      var range = DayDateTimeRange(dateTime);

      expect(range.fromDateTime, DateTime(2020, 3, 19));
      expect(range.toDateTime, DateTime(2020, 3, 19, 23, 59, 59));

      expect(range.matchDatetime(dateTime), true);

      expect(range.toString(), "2020-03-19");
    });
    
    test("Дейтренж недели", () {
      var range = WeekDateRange(DateTime(2020, 3, 27));
      
      expect(range.fromDateTime, DateTime(2020, 3, 23));
      expect(range.toDateTime, DateTime(2020, 3, 29, 23, 59, 59));

      expect(range.toString(), "2020-03-23 - 2020-03-29");
    });
  });
}

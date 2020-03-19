import 'package:flutter_test/flutter_test.dart';
import 'package:yahta/direction.dart';

void main() {
  test("Direction identification correctness", () {
    expect(Direction(0, 2).type, Direction.RIGHT);
    expect(Direction(2, 1).type, Direction.RIGHT);
    expect(Direction(1, 0).type, Direction.RIGHT);
    expect(Direction(0, 1).type, Direction.LEFT);
    expect(Direction(1, 2).type, Direction.LEFT);
    expect(Direction(2, 0).type, Direction.LEFT);

    expect(() => Direction(3, 0), throwsAssertionError);
    expect(() => Direction(0, 3), throwsAssertionError);
  });
}

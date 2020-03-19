class Direction {
  static const RIGHT = "right";
  static const LEFT = "left";

  int fromIndex;
  int toIndex;

  Direction(int fromIndex, int toIndex) {
    assert(fromIndex >= 0 && fromIndex <= 2);
    assert(toIndex >= 0 && toIndex <= 2);

    this.fromIndex = fromIndex;
    this.toIndex = toIndex;
  }

  get type {
    if (fromIndex == 0 && toIndex == 2 ||
        fromIndex == 2 && toIndex == 1 ||
        fromIndex == 1 && toIndex == 0) {
      return RIGHT;
    } else {
      return LEFT;
    }
  }
}

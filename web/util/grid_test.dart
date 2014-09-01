import 'package:unittest/unittest.dart';

import 'grid.dart';

main() {
  test('coordinates passed to default func correctly', () {
    var g = new Grid<bool>(5, 10, (x, y) => x == 1 && y == 2);
    expect(g.get(0, 0), isFalse);
    expect(g.get(2, 2), isFalse);
    expect(g.get(1, 2), isTrue);
  });
}
library image_unittest;

import 'dart:html';
import 'package:unittest/unittest.dart';
import './util.dart' as util;

main() {
  group('Image tests', () {
    var image = new util.Image(null, new Rectangle<int>(0, 0, 10, 10));
    test('splitWidth properties', () {
      var subImages = image.splitWidth(5);
      for (util.Image subImage in subImages) {
        expect(subImage.width, equals(5));
        expect(subImage.height, equals(10));
      }
    });
    test('splitHeight properties', () {
      var subImages = image.splitHeight(5);
      for (util.Image subImage in subImages) {
        expect(subImage.width, equals(10));
        expect(subImage.height, equals(5));
      }
    });
    test('gets offsets right', () {
      image = new util.Image(null, new Rectangle<int>(10, 10, 10, 10));
      var subImages = image.splitWidth(5);
      expect(subImages[0].left, equals(10));
      expect(subImages[1].left, equals(15));
    });
  });
}
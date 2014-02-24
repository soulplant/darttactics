part of tactics_util;

class Image {
  ImageElement _element;
  Rectangle<int> _bounds;
  Image(this._element, [this._bounds]) {
    if (_bounds == null) {
      _bounds = new Rectangle<int>(0, 0, _element.width, _element.height);
    }
  }

  Image.fromSize(ImageElement element, int widthPx, int heightPx) :
    this(element, new Rectangle<int>(0, 0, widthPx, heightPx));

  int get width => _bounds.width;
  int get height => _bounds.height;
  int get left => _bounds.left;
  int get top => _bounds.top;

  List<Image> splitWidth(int widthPx) {
    var result = [];
    int frames = (_bounds.width / widthPx).floor();
    Rectangle<int> frameRect(int i) =>
        new Rectangle<int>(_bounds.left + i * widthPx, _bounds.top, widthPx, _bounds.height);
    for (int i = 0; i < frames; i++) {
      result.add(new Image(_element, frameRect(i)));
    }
    return result;
  }

  List<Image> splitHeight(int heightPx) {
    var result = [];
    int frames = (_bounds.height / heightPx).floor();
    Rectangle<int> frameRect(int i) =>
        new Rectangle<int>(0, i * heightPx, _bounds.width, heightPx);
    for (int i = 0; i < frames; i++) {
      result.add(new Image(_element, frameRect(i)));
    }
    return result;
  }

  void draw(CanvasRenderingContext2D context, int x, int y) {
    var target = _moveRect(_bounds, x, y);
    context.drawImageToRect(_element, target, sourceRect: _bounds);
  }

  Rectangle<int> _moveRect(Rectangle<int> r, int x, int y) {
    return new Rectangle<int>(x, y, r.width, r.height);
  }
}

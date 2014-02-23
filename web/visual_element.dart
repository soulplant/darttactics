
part of tactics;

class VisualElement implements Positioned {
  int _x = 0;
  int _y = 0;
  int _width = 0;
  int _height = 0;
  List<VisualElement> _children = [];

  Point<int> get pos => new Point<int>(x, y);
  Rectangle<int> get bounds => new Rectangle<int>(x, y, width, height);
  void set bounds(Rectangle<int> bounds) {
    _x = bounds.left;
    _y = bounds.top;
    _width = bounds.width;
    _height = bounds.height;
  }

  void set pos(Point<int> pos) {
    _x = pos.x;
    _y = pos.y;
  }

  void set x(v) { _x = v; }
  void set y(v) { _y = v; }
  void set width(v) { _width = v; }
  void set height(v) { _height = v; }
  int get x => _x;
  int get y => _y;
  int get width => _width;
  int get height => _height;

  void draw(CanvasRenderingContext2D context) {
    context.save();
    context.translate(x, y);

    doDraw(context);
    for (var c in _children) {
      context.save();
      c.draw(context);
      context.restore();
    }
    context.restore();
  }
  void doDraw(CanvasRenderingContext2D context) {}

  void add(VisualElement e) => _children.add(e);
  bool remove(VisualElement e) => _children.remove(e);
}

class SpriteElement extends VisualElement {
  Map<String, ImageElement> _images;
  String _currentImageName;
  bool _hasBorder = false;

  SpriteElement(this._images, this._currentImageName) {
    bounds = new Rectangle<int>(0, 0, _currentImage.width, _currentImage.height);
  }

  ImageElement get _currentImage => _images[_currentImageName];
  void set frame(String f) {
    if (!_images.containsKey(_currentImageName)) {
      throw new Exception("Don't have image $f");
    }
    _currentImageName = f;
  }

  void doDraw(CanvasRenderingContext2D context) {
    context.drawImage(_currentImage, 0, 0);
    if (_hasBorder) {
      context.fillStyle = 'black';
      context.strokeRect(0, 0, _currentImage.width, _currentImage.height);
    }
  }

  void set border(bool b) {
    _hasBorder = b;
  }

  setFacing(Point<int> delta) {
    if (delta.x < 0) {
      frame = 'left';
    } else if (delta.x > 0) {
      frame = 'right';
    } else if (delta.y < 0) {
      frame = 'up';
    } else if (delta.y > 0) {
      frame = 'down';
    }
  }
}

class SquareElement extends VisualElement {
  void doDraw(CanvasRenderingContext2D context) {
    context.fillStyle = 'black';
    context.strokeRect(0, 0, width, height);
  }
}
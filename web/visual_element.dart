
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
  SpriteMap _spriteMap;
  bool _hasBorder = false;
  List<Image> _animation;
  int _frame = 0;

  SpriteElement(this._spriteMap, String imageName) {
    _animation = _spriteMap.getAnimation(imageName);
    _checkAnimation(imageName);
  }

  void _checkAnimation(imageName) {
    if (_animation == null) {
      print(_spriteMap.animations);
      throw new Exception("unknown animation $imageName");
    }
  }

  void set animation(String f) {
    _animation = _spriteMap.getAnimation(f);
    _checkAnimation(f);
  }

  int get frameCount => _animation.length;

  void set frame(int x) {
    _frame = x;
  }

  void doDraw(CanvasRenderingContext2D context) {
    _animation[_frame].draw(context, 0, 0);
    if (_hasBorder) {
      context.fillStyle = 'black';
      context.strokeRect(0, 0, _spriteMap.widthPx + 1, _spriteMap.heightPx+ 1);
    }
  }

  void set border(bool b) {
    _hasBorder = b;
  }

  setFacing(Point<int> delta) {
    if (delta.x < 0) {
      animation = 'left';
    } else if (delta.x > 0) {
      animation = 'right';
    } else if (delta.y < 0) {
      animation = 'up';
    } else if (delta.y > 0) {
      animation = 'down';
    }
  }
}

class SquareElement extends VisualElement {
  void doDraw(CanvasRenderingContext2D context) {
    context.fillStyle = 'black';
    context.strokeRect(0, 0, width, height);
  }
}
part of tactics;

class Sprite extends Entity implements Positioned {
  Point<int> _pos;
  Map<String, ImageElement> _images;
  String _facing = 'down';

  Sprite(this._images, this._pos);

  Point<int> get pos => _pos;

  void draw(CanvasRenderingContext2D context) {
    super.draw(context);
    context.drawImage(_images[_facing], _pos.x, _pos.y);
  }

  void moveBy(Point<int> delta) {
    _pos += delta;
  }

  Future slideTo(Point<int> target, int durationMs) {
    var slider = new PositionSlider(this, target, durationMs);
    add(slider);
    return slider.onDead;
  }

  setFacing(Point<int> delta) {
    if (delta.x < 0) {
      _facing = 'left';
    } else if (delta.x > 0) {
      _facing = 'right';
    } else if (delta.y < 0) {
      _facing = 'up';
    } else if (delta.y > 0) {
      _facing = 'down';
    }
  }

  void set pos(Point<int> point) {
    _pos = point;
  }
}

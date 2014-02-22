part of tactics;

class Sprite extends Entity implements Positioned {
  Point<int> _pos;
  Map<String, ImageElement> _images;
  String _imageName = 'down';

  Sprite(this._images, this._pos);

  Point<int> get pos => _pos;

  void draw(CanvasRenderingContext2D context) {
    super.draw(context);
    context.drawImage(_images[_imageName], _pos.x, _pos.y);
  }

  void moveBy(Point<int> delta) {
    _pos += delta;
  }

  Future slideTo(Point<int> target, int durationMs) {
    var slider = new PositionSlider(this, _pos, target, durationMs);
    add(slider);
    return slider.onDead;
  }

  setFacing(Point<int> delta) {
    if (delta.x < 0) {
      _imageName = 'left';
    } else if (delta.x > 0) {
      _imageName = 'right';
    } else if (delta.y < 0) {
      _imageName = 'up';
    } else if (delta.y > 0) {
      _imageName = 'down';
    }
  }

  void set pos(Point<int> point) {
    _pos = point;
  }

  void setImage(String name) {
    print('setting image to $name');
    if (!_images.containsKey(name)) {
      throw new Exception("Sprite doesn't contain image '$name'");
    }
    _imageName = name;
  }
}

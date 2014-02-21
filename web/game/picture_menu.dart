part of tactics;

class MenuOption extends Entity {
  String _label;
  Point<int> _pos = new Point<int>(0, 0);
  ImageElement _image;
  bool _selected = false;

  MenuOption(this._label, this._image);

  void set pos(Point<int> p) {
    _pos = p;
  }

  String get label => _label;

  void draw(CanvasRenderingContext2D context) {
    context.drawImage(_image, _pos.x, _pos.y);
    if (_selected) {
      context.fillStyle = 'solid 1px';
      context.strokeRect(_pos.x, _pos.y, _image.width + 1, _image.height + 1);
    }
  }

  void set selected(bool value) {
    _selected = value;
  }
}

class PictureMenu extends Entity implements Positioned {
  static const String CANCELED = 'canceled';
  List<MenuOption> _options;
  MenuOption _selected;
  Point<int> _pos;

  PictureMenu(this._options, String startingOption) {
    for (var o in _options) {
      if (o.label == startingOption) {
        _selected = o;
      }
    }
    pos = startPosition;
  }

  Point<int> get targetPosition =>
      new Point<int>(((SCREEN_WIDTH_PX - TILE_WIDTH_PX) / 2).floor(),
          (SCREEN_HEIGHT_PX - TILE_HEIGHT_PX * 3).floor());

  Point<int> get startPosition {
    var p = targetPosition;
    return new Point<int>(p.x, p.y + 100);
  }

  Point<int> get pos => _pos;

  Future<String> selectItem() {
    var slideIn = blockUntilDead(new PositionSlider(this, pos, targetPosition, MENU_SLIDE_IN_OUT_MS));
    var slideOut = blockUntilDead(new PositionSlider(this, targetPosition, pos, MENU_SLIDE_IN_OUT_MS));
    return enter(slideIn).then((_) =>
        enter(selectItemLoop).then((selection) =>
            enter(slideOut).then((_) => selection)));
  }

  void set pos(Point<int> point) {
    _pos = point;
    var offsets = [[-1, 0], [1, 0], [0, -1], [0, 1]];
    for (var i = 0; i < _options.length; i++) {
      var o = _options[i];
      o.pos = new Point<int>(point.x + offsets[i][0] * TILE_WIDTH_PX,
          point.y + offsets[i][1] * TILE_HEIGHT_PX);
    }
  }

  void onInit() {
    for (var o in _options) {
      add(o);
    }
  }

  void onDie() {
    for (var o in _options) {
      o.die();
    }
  }

  dynamic selectItemLoop(Controller c) {
    var dirs = [c.left, c.right, c.up, c.down];
    for (var i = 0; i < dirs.length; i++) {
      if (dirs[i]) {
        _selected = _options[i];
        break;
      }
    }

    for (var o in _options) {
      o.selected = o == _selected;
    }

    if (c.action) {
      return _selected.label;
    }

    if (c.cancel) {
      return CANCELED;
    }
  }
}
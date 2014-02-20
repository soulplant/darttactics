part of tactics;

class MenuOption extends Entity {
  String _label;
  Point<int> _pos = new Point<int>(0, 0);
  ImageElement _image;

  MenuOption(this._label, this._image);

  void set pos(Point<int> p) {
    _pos = p;
  }

  String get label => _label;

  void draw(CanvasRenderingContext2D context) {
    context.drawImage(_image, _pos.x, _pos.y);
  }
}

class PictureMenu extends Entity {
  static const String CANCELED = 'canceled';
  List<MenuOption> _options;
  MenuOption _selected;
  PictureMenu(this._options) {
    _selected = _options[0];
    var basePosition = new Point<int>(((SCREEN_WIDTH_PX - TILE_WIDTH_PX) / 2).floor(),
        (SCREEN_HEIGHT_PX - TILE_HEIGHT_PX * 3).floor());
    var offsets = [[-1, 0], [1, 0], [0, -1], [0, 1]];
    for (var i = 0; i < _options.length; i++) {
      var o = _options[i];
      o.pos = new Point<int>(basePosition.x + offsets[i][0] * TILE_WIDTH_PX,
          basePosition.y + offsets[i][1] * TILE_HEIGHT_PX);
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

    if (c.actionRecent) {
      return _selected.label;
    }

    if (c.cancel) {
      return CANCELED;
    }
  }
}
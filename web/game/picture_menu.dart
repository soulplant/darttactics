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
      context.strokeStyle = 'black';
      context.strokeRect(_pos.x, _pos.y, _image.width + 1, _image.height + 1);
    }
  }

  void set selected(bool value) {
    _selected = value;
  }
}

class PictureMenuRunner {
  Entity _entity;
  Map<String, ImageElement> _images;
  PictureMenuRunner(this._entity, this._images);

  Exit<String> runMenu(String startingOption) {
    var optionNames = ['attack', 'item', 'magic', 'stay'];
    var options = new List.from(optionNames.map((n) => new MenuOption(n, _images['$n-icon'])));
    var menu = new PictureMenu(options, startingOption);
    _entity.add(menu);
    return menu.selectItem().exit((item) {
      menu.die();
      return item;
    });
  }
}

class PictureMenu extends Entity implements Positioned {
  static const String CANCELED = 'canceled';
  List<MenuOption> _options;
  MenuOption _selected;
  Point<int> _pos;

  PictureMenu(this._options, String startingOption) {
    for (var option in _options) {
      if (option.label == startingOption) {
        _selected = option;
      }
      option.selected = option.label == startingOption;
      addChild(option);
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

  Exit<String> selectItem() {
    var slideIn = new PositionSlider(this, pos, targetPosition, MENU_SLIDE_IN_OUT_MS);
    var slideOut = new PositionSlider(this, targetPosition, pos, MENU_SLIDE_IN_OUT_MS);
    return blockUntilDead(slideIn).exit((_) =>
        enter(selectItemLoop).exit((selection) =>
            blockUntilDead(slideOut).exit((_) => selection)));
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
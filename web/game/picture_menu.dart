part of tactics;

class MenuElement extends VisualElement {
  SpriteMap _spriteMap;
  List<String> _options;
  Map<String, SpriteElement> _items = {};

  MenuElement(this._spriteMap, this._options) {
    x = 0;
    y = 0;
    width = 3 * TILE_WIDTH_PX;
    height = 3 * TILE_HEIGHT_PX;

    var offsets = [[-1.0, 0.0], [1.0, 0.0], [0.0, -0.5], [0.0, 0.5]];
    for (var i = 0; i < _options.length; i++) {
      var optionName = _options[i];
      var menuItem = new SpriteElement(_spriteMap, optionName);
      menuItem.pos = new Point<int>(((offsets[i][0] + 1) * TILE_WIDTH_PX).floor(),
          ((offsets[i][1] + 1) * TILE_HEIGHT_PX).floor());
      add(menuItem);
      _items[optionName] = menuItem;
    }
  }

  void select(String name) {
    for (var n in _items.keys) {
      _items[n].frame = (n == name) ? 1 : 0;
    }
  }
}

class PictureMenuRunner {
  Entity _entity;
  SpriteMap _spriteMap;
  PictureMenuRunner(this._entity, this._spriteMap);

  Exit<String> runMenu(String startingOption) {
    var optionNames = ['attack', 'item', 'magic', 'stay'];
    var view = new MenuElement(_spriteMap, optionNames);
    var menu = new PictureMenu(view, optionNames, startingOption);
    _entity.add(menu);
    return menu.selectItem().exit((item) {
      menu.die();
      return item;
    });
  }
}

class PictureMenu extends Entity implements Positioned {
  static const String CANCELED = 'canceled';
  List<String> _options;
  String _selected;
  MenuElement _view;

  PictureMenu(this._view, this._options, this._selected) {
    print('viewbounds = ${_view.bounds}');
    print('startPosition = $startPosition');
    print('targetPosition = $targetPosition');
    _view.select(_selected);
    pos = startPosition;
  }

  void onInit() {
    addVisual(_view);
  }

  void onDie() {
    removeVisual(_view);
  }

  Point<int> get targetPosition =>
      new Point<int>(((SCREEN_WIDTH_PX - _view.width) / 2).floor(),
          (SCREEN_HEIGHT_PX - _view.height).floor());

  Point<int> get startPosition {
    var p = targetPosition;
    return new Point<int>(p.x, p.y + 80);
  }

  Exit<String> selectItem() {
    Point<int> pos = startPosition;
    return slideTo(_view, pos, targetPosition, MENU_SLIDE_IN_OUT_MS).exit((_) =>
        enter(selectItemLoop).exit((selection) =>
            slideTo(_view, targetPosition, pos, MENU_SLIDE_IN_OUT_MS).exit((_) => selection)));
  }

  dynamic selectItemLoop(Controller c) {
    var dirs = [c.left, c.right, c.up, c.down];
    for (var i = 0; i < dirs.length; i++) {
      if (dirs[i]) {
        _selected = _options[i];
        _view.select(_selected);
        break;
      }
    }

    if (c.action) {
      return _selected;
    }

    if (c.cancel) {
      return CANCELED;
    }
  }

  Point<int> get pos => _view.pos;

  void set pos(Point<int> p) {
    _view.pos = p;
  }
}

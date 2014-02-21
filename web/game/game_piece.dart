part of tactics;

/**
 * Represents a 'piece' in the game, ie: something that can move and attack in
 * the tactical game.
 */
class GamePiece extends Entity {
  Sprite _view;
  Point<int> _pos;
  Map<String, ImageElement> _menuImages;

  GamePiece(Map<String, ImageElement> images, this._menuImages, this._pos) {
    _view = new Sprite(images, scalePoint(_pos, TILE_WIDTH_PX));
  }

  void onInit() {
    add(_view);
  }

  void onDie() {
    _view.die();
    _view = null;
  }

  Point<int> get viewPos {
    return _view._pos;
  }

  dynamic makeMoveInputLoop(Controller controller) {
    Point<int> delta = controller.direction;
    if (delta != null) {
      _pos += delta;
      _view.setFacing(delta);
      return blockInputWhile(_view.slideTo(scalePoint(_pos, TILE_WIDTH_PX), 270));
    }
    if (controller.action) {
      var menu = new PictureMenu(getBattleActions(), 'stay');
      add(menu);
      return menu.selectItem().then((item) {
        menu.die();
        if (item == PictureMenu.CANCELED) {
          return makeMoveInputLoop;
        }
        _view.setFacing(new Point(0, 1));
        return true;
      });
    }
    return null;
  }

  List<MenuOption> getBattleActions() {
    var options = ['attack', 'item', 'magic', 'stay'];
    return new List.from(options.map((f) => new MenuOption(f, _menuImages['$f-icon'])));
  }

  Future makeMove() {
    return getFocusStack().enter(makeMoveInputLoop);
  }
}

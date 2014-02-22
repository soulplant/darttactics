part of tactics;

/**
 * Represents a 'piece' in the game, ie: something that can move and attack in
 * the tactical game.
 */
class GamePiece extends Entity {
  Sprite _view;
  Point<int> _pos;
  Map<String, ImageElement> _menuImages;
  PictureMenuRunner _menuRunner;

  GamePiece(Map<String, ImageElement> images, this._menuRunner, this._pos) {
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
      return blockInputUntil(_view.slideTo(scalePoint(_pos, TILE_WIDTH_PX), 270));
    }

    if (controller.action) {
      return _menuRunner.runMenu('stay').then((item) {
        print('got $item from the menu');
        if (item == PictureMenu.CANCELED) {
          return null;
        }
        _view.setFacing(new Point(0, 1));
        return true;
      });
    }
  }

  Future makeMove() {
    return getFocusStack().enter(makeMoveInputLoop);
  }
}

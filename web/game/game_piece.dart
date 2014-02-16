part of tactics;

/**
 * Represents a 'piece' in the game, ie: something that can move and attack in
 * the tactical game.
 */
class GamePiece extends Entity implements KeyFocusHandler {
  Sprite _view;
  Point<int> _pos;

  GamePiece(Map<String, ImageElement> images, this._pos) {
    _view = new Sprite(images, scalePoint(_pos, 16));
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

  bool inputUpdated(Controller controller) {
    Point<int> delta = controller.direction;
    if (delta != null) {
      _pos += delta;
      _view.setFacing(delta);
      blockInputWhile(_view.slideTo(scalePoint(_pos, 16), 200));
      return false;
    }
    if (controller.actionRecent) {
      _view.setFacing(new Point(0, 1));
      return true;
    }
    return false;
  }

  void onFirstInput() {
  }

  Future makeMove() {
    return getFocusStack().push(this);
  }
}

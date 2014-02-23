part of tactics;

class Cursor extends Entity {
  static const int CURSOR_PPS = 120;
  static const double CURSOR_PPT = CURSOR_PPS / FPS;
  Point<double> _realPos;
  Point<int> _target;
  bool _reachedTarget = true;
  Completer _completion;
  SquareElement _view = new SquareElement();

  Cursor(Entity root, pos) {
    _realPos = new Point<double>(pos.x.toDouble(), pos.y.toDouble());
    _view.pos = pos;
    _view.width = TILE_WIDTH_PX;
    _view.height = TILE_HEIGHT_PX;
    root.add(this);
  }

  void onInit() {
    addVisual(_view);
  }

  void onDie() {
    removeVisual(_view);
  }

  void tick() {
    if (_completion != null) {
      moveCloserToTarget();
    }
  }

  Future moveToTarget(Point<int> target) {
    _completion = new Completer.sync();
    _target = target;
    return _completion.future;
  }

  Future moveToTargetAndDie(Point<int> target) {
    return moveToTarget(target).then((_) => die());
  }

  moveCloserToTarget() {
    if (_completion != null && _view.pos == _target) {
      _completion.complete();
      _completion = null;
      return;
    }
    var dx = clampDouble((_target.x - _view.pos.x).toDouble(), CURSOR_PPT);
    var dy = clampDouble((_target.y - _view.pos.y).toDouble(), CURSOR_PPT);
    _realPos += new Point<double>(dx, dy);
    _view.pos = new Point<int>(_realPos.x.floor(), _realPos.y.floor());
  }

  bool get isAtTarget => _view.pos == _target;
}

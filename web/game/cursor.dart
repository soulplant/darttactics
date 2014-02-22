part of tactics;

class Cursor extends Entity {
  static const int CURSOR_PPS = 120;
  static const double CURSOR_PPT = CURSOR_PPS / FPS;
  Point<int> _pos;
  Point<double> _realPos;
  Point<int> _target;
  bool _reachedTarget = true;
  Completer _completion;

  Cursor(Entity root, this._pos) {
    _target = _pos;
    _realPos = new Point<double>(_pos.x.toDouble(), _pos.y.toDouble());
    root.add(this);
  }

  void tick() {
    if (_completion != null) {
      moveCloserToTarget();
    }
  }

  void draw(CanvasRenderingContext2D context) {
    context.strokeStyle = 'black';
    context.strokeRect(_pos.x, _pos.y, 16, 16);
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
    if (_completion != null && _pos == _target) {
      _completion.complete();
      _completion = null;
      return;
    }
    var dx = clampDouble((_target.x - _pos.x).toDouble(), CURSOR_PPT);
    var dy = clampDouble((_target.y - _pos.y).toDouble(), CURSOR_PPT);
    _realPos += new Point<double>(dx, dy);
    _pos = new Point<int>(_realPos.x.floor(), _realPos.y.floor());
  }

  bool get isAtTarget => _pos == _target;
}

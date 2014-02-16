part of tactics;

class PositionSlider extends Entity {
  Sprite _sprite;
  Point<int> _endPos;
  Point<int> _startPos;
  int _durationTicks;
  int _elapsedTicks = 0;

  PositionSlider(this._sprite, this._endPos, int durationMs) {
    _startPos = _sprite.pos;
    _durationTicks = math.max(1, msToTicks(durationMs));
  }

  void tick() {
    _elapsedTicks++;
    double percentComplete = _elapsedTicks / _durationTicks;
    var delta = _endPos - _startPos;
    delta = new Point<int>((percentComplete * delta.x).floor(),
        (percentComplete * delta.y).floor());
    _sprite.setPosition(_startPos + delta);
    if (_elapsedTicks == _durationTicks) {
      die();
    }
  }
}

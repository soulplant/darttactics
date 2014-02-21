part of tactics;

class PositionSlider extends Entity {
  Positioned _thingToSlide;
  Point<int> _endPos;
  Point<int> _startPos;
  int _durationTicks;
  int _elapsedTicks = 0;

  PositionSlider(this._thingToSlide, this._startPos, this._endPos, int durationMs) {
    _durationTicks = max(1, msToTicks(durationMs));
  }

  void tick() {
    _elapsedTicks++;
    double percentComplete = _elapsedTicks / _durationTicks;
    var delta = _endPos - _startPos;
    delta = new Point<int>((percentComplete * delta.x).floor(),
        (percentComplete * delta.y).floor());
    _thingToSlide.pos = _startPos + delta;
    if (_elapsedTicks == _durationTicks) {
      die();
    }
  }
}

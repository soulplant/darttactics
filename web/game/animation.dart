part of tactics;

class Animation extends Entity {
  List<Image> _frames;
  int _frameDuration;
  Animation(this._frames, int frameDurationMs) {
    _frameDuration = msToTicks(frameDurationMs);
  }
}

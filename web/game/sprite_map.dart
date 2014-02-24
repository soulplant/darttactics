part of tactics;

class SpriteMap {
  Map<String, List<Image>> _animations = {};
  int _widthPx;
  int _heightPx;
  String _defaultAnimation;

  SpriteMap(this._widthPx, this._heightPx);

  int get widthPx => _widthPx;
  int get heightPx => _heightPx;
  List<String> get animations => _animations.keys.toList();

  void addAnimation(String name, List<Image> frames) {
    _animations[name] = frames;
    _defaultAnimation = name;
  }

  void addAnimationsFromSpriteSheet(Image image, List<String> names) {
    var rows = image.splitHeight(_heightPx);
    if (rows.length != names.length) {
      print("rows length = ${rows.length}, imageHeight = ${image.height}, names = ${names}");
    }
    for (int i = 0; i < names.length; i++) {
      addAnimation(names[i], rows[i].splitWidth(_widthPx));
    }
  }

  List<Image> getAnimation(String name) {
    if (_animations.containsKey(name)) {
      return _animations[name];
    }
    return _animations[_defaultAnimation];
  }

  /*
  void setAnimationNames(List<String> names) { _names = names; }
  void setAnimation(String name) {
    if (!_names.contains(name)) {
      throw new Exception("Unknown animation: $name");
    }
    _currentAnimation = _names.indexOf(name);
  }
  void set frame(int x) {
    _currentFrame = x;
    _currentFrame = max(0, min(_frames, _currentFrame));
  }

  void run(int rate, ctx) {
    new Timer.periodic(new Duration(milliseconds: rate), (_) {
      draw(ctx);
      advanceFrame();
    });
  }

  advanceFrame() {
    _currentFrame++;
    _currentFrame %= _frames;
  }

  void draw(CanvasRenderingContext2D context) {
    context.clearRect(0, 0, _widthPx, _heightPx);
    var target = new Rectangle(0, 0, _widthPx, _heightPx);
    var source = new Rectangle(_currentFrame * _widthPx, _currentAnimation * _heightPx, _widthPx, _heightPx);
    context.drawImageToRect(_image, target, sourceRect: source);
  }
  */
}
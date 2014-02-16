part of tactics;

class Controller {
  static const int VKEY_LEFT = 37;
  static const int VKEY_UP = 38;
  static const int VKEY_RIGHT = 39;
  static const int VKEY_DOWN = 40;
  static const int VKEY_ENTER = 13;
  static const int VKEY_SEMICOLON = 186;
  static const int VKEY_ESCAPE = 27;

  Set<int> _keys = new Set();
  Set<int> _recent = new Set();
  Set<int> _removals = new Set();

  void onKeyDown(int keyCode) {
    // We can get multiple onKeyDown() calls while a key is held down because
    // of auto-repeat.
    if (_keys.add(keyCode)) {
      _recent.add(keyCode);
    }
    _removals.remove(keyCode);
  }

  void onKeyUp(int keyCode) {
    _removals.add(keyCode);
  }

  void tick() {
    _recent.clear();
    _keys.removeAll(_removals);
    _removals.clear();
  }

  bool isKeyDown(int keyCode) {
    return _keys.contains(keyCode);
  }

  bool isKeyRecent(int keyCode) {
    return _recent.contains(keyCode);
  }

  bool get left => isKeyDown(VKEY_LEFT);
  bool get right => isKeyDown(VKEY_RIGHT);
  bool get up => isKeyDown(VKEY_UP);
  bool get down => isKeyDown(VKEY_DOWN);
  bool get action => isKeyDown(VKEY_ENTER);
  bool get actionRecent => action && isKeyRecent(VKEY_ENTER);

  Point<int> get direction {
    if (left) {
      return new Point(-1, 0);
    }
    if (right) {
      return new Point(1, 0);
    }
    if (up) {
      return new Point(0, -1);
    }
    if (down) {
      return new Point(0, 1);
    }
    return null;
  }
}

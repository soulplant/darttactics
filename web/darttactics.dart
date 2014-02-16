library tactics;

import 'dart:html';
import 'dart:async';

part 'engine/key_focus_stack.dart';
part 'engine/key_focus_handler.dart';
part 'engine/controller.dart';

class TileMap {
  static const GRASS = 'grass';
  static const DIRT = 'dirt';
  int _width;
  int _height;
  Map _imageMap;
  Function _tiles = (x, y) => x < 5 ? GRASS : DIRT;

  TileMap(this._width, this._height, this._imageMap);

  void draw(CanvasRenderingContext2D context) {
    for (var i = 0; i < _width; i++) {
      for (var j = 0; j < _height; j++) {
        context.drawImage(_imageMap[_tiles(i, j)], i * 16, j * 16);
      }
    }
  }
}

class ImageLoader {
  int _outstandingLoads = 0;
  List<Function> _listeners = [];

  ImageElement loadImage(String filename) {
    _outstandingLoads++;
    var image = new ImageElement(src: filename);
    image.onLoad.first.then(onLoadDone);
    return image;
  }

  Map<String, ImageElement> loadImages(List<String> names) {
    var result = {};
    for (var name in names) {
      result[name] = loadImage('gfx/' + name + '.png');
    }
    return result;
  }

  void onLoadDone(Event event) {
    _outstandingLoads--;
    if (_outstandingLoads == 0) {
      for (var listener in _listeners) {
        listener();
      }
    }
  }

  Map<String, ImageElement> loadImageMapFromDir(String name) {
    var images = {};
    for (var direction in ['left', 'right', 'up', 'down']) {
      var filename = 'gfx/' + name + '-' + direction[0] + '.png';
      images[direction] = loadImage(filename);
    }
    return images;
  }

  void addListener(Function listener) => _listeners.add(listener);
}

class EntitySet {
  List<Entity> _entities;
  void tick() {
    for (var e in _entities) {
      e.tick();
    }
  }
}

abstract class Ticker {
  void tick();
  bool get alive;
}

class Entity implements Ticker {
  Entity _parent;
  bool _alive = true;
  bool _inited = false;
  List<Entity> _children = [];
  Completer _completer = new Completer();
  KeyFocusStack _focusStack;

  Entity([this._focusStack]);

  void baseTick() {
    var children = [];
    children.addAll(_children);

    children.where((c) => !c.alive).forEach((c) => c.onDie());
    children.where((c) => c.alive).forEach((c) {
      c.ensureInited();
      c.tick();
    });

    _children.removeWhere((c) => !c.alive);

    tick();
  }

  void ensureInited() {
    if (_inited) {
      return;
    }
    onInit();
    _inited = true;
  }

  Future blockInputWhile(Future f) => getFocusStack().blockInputWhile(f);

  void onInit() {}
  void onDie() {}

  void die() {
    onDie();
    _completer.complete();
    _alive = false;
  }

  void tick() {}

  void add(Entity entity) {
    if (_parent == null) {
      addChild(entity);
    } else {
      _parent.add(entity);
    }
  }

  void remove(Entity entity) {
    if (_parent == null) {
      removeChild(entity);
    } else {
      _parent.remove(entity);
    }
  }

  void draw(CanvasRenderingContext2D context) {
    _children.forEach((c) => c.draw(context));
  }

  void addChild(Entity entity) {
    _children.add(entity);
    entity._parent = this;
  }

  void removeChild(Entity entity) {
    _children.remove(entity);
    entity._parent = null;
  }

  KeyFocusStack getFocusStack() {
    if (_parent != null) {
      return _parent.getFocusStack();
    }
    return _focusStack;
  }

  bool get alive => _alive;
  Future get onDead => _completer.future;
}

class Sprite extends Entity {
  Point<int> _pos;
  Map<String, ImageElement> _images;
  String _facing = 'down';

  Sprite(this._images, this._pos);

  Point<int> get pos => _pos;

  void draw(CanvasRenderingContext2D context) {
    super.draw(context);
    context.drawImage(_images[_facing], _pos.x, _pos.y);
  }

  void moveBy(Point<int> delta) {
    _pos += delta;
  }

  Future slideTo(Point<int> target) {
    var slider = new PositionSlider(this, target);
    add(slider);
    return slider.onDead;
  }

  setFacing(Point<int> delta) {
    if (delta.x < 0) {
      _facing = 'left';
    } else if (delta.x > 0) {
      _facing = 'right';
    } else if (delta.y < 0) {
      _facing = 'up';
    } else if (delta.y > 0) {
      _facing = 'down';
    }
  }
}

class PositionSlider extends Entity {
  Sprite _sprite;
  Point<int> _target;
  PositionSlider(this._sprite, this._target);

  void tick() {
    if (_sprite.pos == _target) {
      die();
      return;
    }
    var delta = _target - _sprite.pos;
    delta = new Point(signum(delta.x), signum(delta.y));
    _sprite.moveBy(delta);
  }
}

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
      blockInputWhile(_view.slideTo(scalePoint(_pos, 16)));
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

int signum(int x) {
  if (x < 0) {
    return -1;
  }
  if (x > 0) {
    return 1;
  }
  return 0;
}

Point scalePoint(Point p, int factor) => new Point(p.x * factor, p.y * factor);

class Cursor extends Entity {
  Point<int> _pos;
  Point<int> _target;
  bool _reachedTarget = true;
  Completer _completion;

  Cursor(this._pos) {
    _target = _pos;
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
    _completion = new Completer();
    _target = target;
    return _completion.future;
  }

  moveCloserToTarget() {
    if (_completion != null && _pos == _target) {
      _completion.complete();
      _completion = null;
      return;
    }
    var dx = signum(_target.x - _pos.x);
    var dy = signum(_target.y - _pos.y);
    _pos += new Point(dx, dy);
  }
}

void main() {
  CanvasElement canvas = querySelector("#canvas");
  CanvasRenderingContext2D context = canvas.getContext('2d');
  context.imageSmoothingEnabled = false;
  context.translate(0.5, 0.5);
  Controller controller = new Controller();
  var loader = new ImageLoader();
  var fighterImages = loader.loadImageMapFromDir('fighter');
  var tileImages = loader.loadImages(['grass', 'dirt']);
  var directions = ['left', 'right', 'up', 'down'];
  var tileMap = new TileMap((320 / 16).floor(), (240 / 16).floor(), tileImages);
  var focusStack = new KeyFocusStack();

  var root = new Entity(focusStack);
  var green = new GamePiece(fighterImages, new Point(0, 0));
  var red = new GamePiece(fighterImages, new Point(5, 5));
  root.add(green);
  root.add(red);

  loop(GamePiece p1, GamePiece p2) {
    Cursor cursor = new Cursor(p2.viewPos);
    root.add(cursor);
    cursor.moveToTarget(p1.viewPos).then((_) {
      cursor.die();
      p1.makeMove().then((_) => loop(p2, p1));
    });
  }

  loop(green, red);

  gameLoop(double timeElapsed) {
    context.clearRect(0, 0, canvas.width, canvas.height);
    tileMap.draw(context);
    root.baseTick();
    focusStack.inputUpdated(controller);
    controller.clearRecent();
    root.draw(context);
    window.animationFrame.then(gameLoop);
  }
  loader.addListener(() => gameLoop(0.0));
  document.body.onKeyDown.listen((e) => controller.onKeyDown(e.keyCode));
  document.body.onKeyUp.listen((e) => controller.onKeyUp(e.keyCode));
}

class WaitForKey extends KeyFocusHandler {
  int _key;
  WaitForKey(this._key);
  bool inputUpdated(Controller controller) {
    return controller.isKeyDown(_key);
  }
}

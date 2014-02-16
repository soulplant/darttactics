library tactics;

import 'dart:async';
import 'dart:html';
import 'dart:math' as math;
import 'package:stats/stats.dart';

import 'util.dart';

part 'engine/key_focus_stack.dart';
part 'engine/key_focus_handler.dart';
part 'engine/controller.dart';
part 'engine/entity.dart';
part 'game/sprite.dart';
part 'game/position_slider.dart';
part 'game/game_piece.dart';
part 'game/tile_map.dart';
part 'game/cursor.dart';

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

void main() {
  Stats s = new Stats();
  document.body.children.add(s.container);

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

  double startTime = -1.0;
  int tickCount = 0;
  gameLoop(double timeFromStart) {
    if (startTime == -1.0) {
      startTime = timeFromStart;
    }
    double timeElapsed = timeFromStart - startTime;
    s.begin();
    double tickDuration = 1000.0 / FPS;
    while (timeElapsed - (tickCount * tickDuration) > tickDuration) {
      focusStack.inputUpdated(controller);
      controller.tick();
      root.baseTick();
      tickCount++;
    }
    context.clearRect(0, 0, canvas.width, canvas.height);
    tileMap.draw(context);
    root.draw(context);
    s.end();
    window.animationFrame.then(gameLoop);
  }
  loader.addListener(() => window.animationFrame.then(gameLoop));
  document.body.onKeyDown.listen((e) => controller.onKeyDown(e.keyCode));
  document.body.onKeyUp.listen((e) => controller.onKeyUp(e.keyCode));
}
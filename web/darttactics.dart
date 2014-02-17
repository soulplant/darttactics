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
  var enemyFighterImages = loader.loadImageMapFromDir('efighter');
  var tileImages = loader.loadImages(['grass', 'dirt']);
  var directions = ['left', 'right', 'up', 'down'];
  var tileMap = new TileMap((320 / 16).floor(), (240 / 16).floor(), tileImages);
  var focusStack = new KeyFocusStack();

  GamePiece fighter(x, y) => new GamePiece(fighterImages, new Point(x, y));
  GamePiece efighter(x, y) => new GamePiece(enemyFighterImages, new Point(x, y));

  var goodGuys = [fighter(0, 0), fighter(1, 0), fighter(0, 1)];
  var badGuys = [efighter(5, 5), efighter(8, 6), efighter(7, 9)];

  var root = new Entity(focusStack);
  for (var g in goodGuys) {
    root.add(g);
  }
  for (var b in badGuys) {
    root.add(b);
  }

  loop(List<GamePiece> currentTeam, List<GamePiece> nextTeam) {
    var currentPlayer = currentTeam.first;
    var lastPlayer = nextTeam.last;
    Cursor cursor = new Cursor(lastPlayer.viewPos);
    root.add(cursor);
    cursor.moveToTarget(currentPlayer.viewPos).then((_) {
      cursor.die();
      currentPlayer.makeMove().then((_) {
        currentTeam.add(currentTeam.removeAt(0));
        loop(nextTeam, currentTeam);
      });
    });
  }

  loop(goodGuys, badGuys);

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
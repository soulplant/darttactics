library darttactics;

import 'dart:async';
import 'dart:html';
import 'package:stats/stats.dart';
import 'tactics.dart';

import 'util.dart';

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


List<MenuOption> getBattleActions(ImageLoader loader) {
  var options = ['attack', 'item', 'magic', 'stay'];
  var optionImages = loader.loadImages(new List.from(options.map((option) => '$option-icon')));
  return new List.from(options.map((f) => new MenuOption(f, optionImages['$f-icon'])));
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
  var menuImages = loader.loadImages(['attack-icon', 'item-icon', 'magic-icon', 'stay-icon']);
  var explosionImages = loader.loadImages(['explosion-1', 'explosion-2', 'explosion-3', 'explosion-4']);
  var tileImages = loader.loadImages(['grass', 'dirt']);
  var tileMap = new TileMap((320 / 16).floor(), (240 / 16).floor(), tileImages);
  KeyFocusStack<Controller> focusStack = new KeyFocusStack<Controller>();
  var root = new Entity(focusStack);
  var menuRunner = new PictureMenuRunner(root, menuImages);

  fighterImages.addAll(explosionImages);
  enemyFighterImages.addAll(explosionImages);

  var board = new GameBoard();

  GamePiece fighter(x, y) {
    var p = new GamePiece(board, fighterImages, menuRunner, new Point(x, y), 0);
    board.addPiece(p);
    return p;
  }
  GamePiece efighter(x, y) {
    var p = new GamePiece(board, enemyFighterImages, menuRunner, new Point(x, y), 1);
    board.addPiece(p);
    return p;
  }

  var goodGuys = [fighter(0, 0), fighter(1, 0), fighter(0, 1)];
  var badGuys = [efighter(5, 5), efighter(8, 6), efighter(7, 9)];
  for (var g in goodGuys) {
    root.add(g);
  }
  for (var b in badGuys) {
    root.add(b);
  }

  Future moveCursorBetween(Point<int> start, Point<int> end) {
    return new Cursor(root, start).moveToTargetAndDie(end);
  }

  var lastPosition = new Point(0, 0);
  focusStack.enter((controller) {
    var piece = board.currentPiece;
    return focusStack.blockInputUntil(moveCursorBetween(lastPosition, piece.viewPos)).exit((_) {
      return piece.makeMove().exit((_) {
        if (board.isGameOver) {
          return true;
        }
        board.nextTurn();
        lastPosition = piece.viewPos;
      });
    });
  }).exit((r) {
    print("The game is over");
  });

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
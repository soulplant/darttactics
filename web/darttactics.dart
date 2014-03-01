library darttactics;

import 'dart:async';
import 'dart:html';
import 'package:stats/stats.dart';
import 'tactics.dart';

import 'util.dart';

class Camera {
  VisualElement _element;
  int _x = 0;
  int _y = 0;
  Camera(this._element) {
    moveTo(_x, _y);
  }

  void moveTo(int x, int y) {
    _x = x;
    _y = y;
    _element.x = -1 - x;
    _element.y = -1 - y;
  }
}

class CameraDragger {
  Element _elem;
  int _x = 0;
  int _y = 0;
  CameraDragger(this._elem, Camera c) {
    bool mouseDown = false;
    _elem.onMouseDown.listen((_) => mouseDown = true);
    _elem.onMouseUp.listen((_) => mouseDown = false);
    _elem.onMouseMove.listen((e) {
      if (mouseDown) {
        print(e.movement);
        _x -= e.movement.x;
        _y -= e.movement.y;
        c.moveTo(_x, _y);
      }
    });
  }
}

void mainForSpriteRunner() {
  CanvasElement canvas = querySelector("#canvas");
  CanvasRenderingContext2D context = canvas.getContext('2d');
  context.imageSmoothingEnabled = false;
  context.translate(0.5, 0.5);

  Controller controller = new Controller();
  var loader = new ImageLoader(TILE_WIDTH_PX, TILE_HEIGHT_PX);
  var image = loader.loadImage('gfx/fighter.png');
  loader.addListener(() {
    var sm = new SpriteMap(24, 24);
    sm.addAnimationsFromSpriteSheet(image, ['down', 'left', 'right', 'up']);
  });
}

class Sprites {
  ImageLoader loader;
  List<Image> explosion;
  Map<String, SpriteMap> pieceMaps = {};
  SpriteMap battleMenu;
  SpriteMap tiles;

  Sprites(this.loader) {
    explosion = loader.loadImageList(['explosion-1', 'explosion-2', 'explosion-3', 'explosion-4']);
    var names = ['fighter', 'hamster', 'wizard', 'bear', 'winged'];
    for (var name in names) {
      pieceMaps[name] = singleImageGamePiece('gfx/$name.png');
    }
    battleMenu = loadBattleMenu();
    tiles = loadTiles();
  }

  SpriteMap loadTiles() {
    var imageMap = loader.loadImages(['grass', 'dirt']);
    SpriteMap result = new SpriteMap(TILE_WIDTH_PX, TILE_HEIGHT_PX);
    for (var name in imageMap.keys) {
      result.addAnimation(name, [imageMap[name]]);
    }
    return result;
  }

  SpriteMap getPieceSpriteMap(String pieceName) => pieceMaps[pieceName];

  SpriteMap loadAnimationsFromFile(String filename, List<String> names) {
    var menuImage = loader.loadImage(filename, TILE_WIDTH_PX, TILE_HEIGHT_PX * names.length);
    var spriteMap = new SpriteMap(TILE_WIDTH_PX, TILE_HEIGHT_PX)
        ..addAnimationsFromSpriteSheet(menuImage, names);
    return spriteMap;
  }

  List<Image> _menuAnimation(String name) {
    return loader.loadImageList(['${name}_off', '${name}_on']);
  }

  SpriteMap loadBattleMenu() {
    var names = ['attack', 'item', 'magic', 'stay'];
    SpriteMap result = new SpriteMap(TILE_WIDTH_PX, TILE_HEIGHT_PX);
    for (var name in names) {
      result.addAnimation(name, _menuAnimation(name));
    }
    return result;
  }

  SpriteMap singleImageGamePiece(String filename) {
    Image image = loader.loadImage(filename);
    var spriteMap = new SpriteMap(image.width, image.height);
    for (var name in ['down', 'left', 'right', 'up']) {
      spriteMap.addAnimation(name, [image]);
    }
    spriteMap.addAnimation('explosion', explosion);
    return spriteMap;
  }

  SpriteMap spriteMapGamePiece(String filename) {
    SpriteMap spriteMap =
        loadAnimationsFromFile(filename, ['down', 'left', 'right', 'up']);
    spriteMap.addAnimation('explosion', explosion);
    return spriteMap;
  }
}

void main() {
  Stats fpsCounter = new Stats();
  document.body.children.add(fpsCounter.container);

  CanvasElement canvas = querySelector("#canvas");
  CanvasRenderingContext2D context = canvas.getContext('2d');
  context.imageSmoothingEnabled = false;
  context.translate(0.5, 0.5);

  Controller controller = new Controller();
  var loader = new ImageLoader(TILE_WIDTH_PX, TILE_HEIGHT_PX);
  Sprites sprites = new Sprites(loader);
  var tileMap = new TileMap((320 / TILE_WIDTH_PX).floor(), (240 / TILE_HEIGHT_PX).floor(), sprites.tiles);

  loader.addListener(() {
    var visualRoot = new VisualElement();
    var camera = new Camera(visualRoot);
    new CameraDragger(canvas, camera);
    visualRoot.add(tileMap);
    KeyFocusStack<Controller> focusStack = new KeyFocusStack<Controller>();
    var root = new Entity(focusStack, visualRoot);
    var menuRunner = new PictureMenuRunner(root, sprites.battleMenu);

    var board = new GameBoard();

    GamePiece fighter(name, x, y, good) {
      var spriteMap = sprites.getPieceSpriteMap(name);
      if (spriteMap == null) {
        throw new Exception("spritemap for $name is null");
      }
      var p = new GamePiece(board, spriteMap, menuRunner, new Point(x, y), good ? 0 : 1);
      board.addPiece(p);
      return p;
    }
    GamePiece gfighter(name, x, y) => fighter(name, x, y, true);
    GamePiece efighter(name, x, y) => fighter(name, x, y, false);

    var goodGuys = [gfighter('fighter', 1, 1), gfighter('hamster', 2, 1)];
    var badGuys = [efighter('winged', 5, 5), efighter('bear', 8, 6), efighter('wizard', 7, 9)];
    for (var g in goodGuys) {
      root.add(g);
    }
    for (var b in badGuys) {
      root.add(b);
    }

    Exit moveCursorBetween(Point<int> start, Point<int> end) {
      return focusStack.blockInputUntil(new Cursor(root, start).moveToTargetAndDie(end));
    }

    var lastPosition = new Point(0, 0);
    focusStack.enter((controller) {
      var piece = board.currentPiece;
      return moveCursorBetween(lastPosition, piece.viewPos).exit((_) {
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
      fpsCounter.begin();
      double tickDuration = 1000.0 / FPS;
      while (timeElapsed - (tickCount * tickDuration) > tickDuration) {
        focusStack.inputUpdated(controller);
        controller.tick();
        root.baseTick();
        tickCount++;
      }
      context.clearRect(0, 0, canvas.width, canvas.height);
      visualRoot.draw(context);
      fpsCounter.end();
      window.animationFrame.then(gameLoop);
    }
    window.animationFrame.then(gameLoop);
    document.body.onKeyDown.listen((e) => controller.onKeyDown(e.keyCode));
    document.body.onKeyUp.listen((e) => controller.onKeyUp(e.keyCode));
  });


}

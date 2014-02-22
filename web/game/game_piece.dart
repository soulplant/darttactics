part of tactics;

/**
 * Represents a 'piece' in the game, ie: something that can move and attack in
 * the tactical game.
 */
class GamePiece extends Entity {
  Sprite _view;
  Point<int> _pos;
  Map<String, ImageElement> _menuImages;
  GameBoard _board;
  PictureMenuRunner _menuRunner;
  int _team;
  int _range = 1;

  GamePiece(this._board, Map<String, ImageElement> images, this._menuRunner, this._pos, this._team) {
    _view = new Sprite(images, scalePoint(_pos, TILE_WIDTH_PX));
  }
  Sprite get view => _view; // TODO remove?
  int get team => _team;
  int get range => _range;

  void onInit() {
    add(_view);
  }

  void onDie() {
    _view.die();
    _view = null;
  }

  Point<int> get viewPos => _view._pos;
  Point<int> get pos => _pos;

  dynamic makeMoveInputLoop(Controller controller) {
    Point<int> delta = controller.direction;
    if (delta != null) {
      _pos += delta;
      _view.setFacing(delta);
      return blockInputUntil(_view.slideTo(scalePoint(_pos, TILE_WIDTH_PX), 270));
    }

    if (controller.action) {
      return _menuRunner.runMenu('stay').then((item) {
        print('got $item from the menu');
        switch (item) {
          case PictureMenu.CANCELED:
            return null;
          case 'stay':
            _view.setFacing(new Point(0, 1));
            return true;
          case 'attack':
            return runAttack();
        }
        if (item == PictureMenu.CANCELED) {
          return null;
        }
        _view.setFacing(new Point(0, 1));
        return true;
      });
    }
  }

  Future makeMove() {
    return enter(makeMoveInputLoop);
  }

  Future runAttack() {
    return enter(new ChooseAttackTarget(this, _board).run).then((target) {
      if (target is GamePiece) {
        return enter(new DeathAnimation(target.view, 320).run).then((_) {
          target.die();
          return true;
        });
      }
      return true;
    }).then((_) {
      _view.setFacing(new Point<int>(0, 1));
      return true;
    });
  }
}

class ChooseAttackTarget extends Entity {
  GamePiece _piece;
  GameBoard _board;
  List<GamePiece> _targets;
  Cursor _cursor;

  ChooseAttackTarget(this._piece, this._board) {
    _piece.add(this);
    _targets = _board.getNearbyPieces(_piece.pos, 1 - _piece.team, _piece.range);
    _cursor = new Cursor(_piece, _piece.viewPos);
  }

  dynamic run(Controller controller) {
    if (_targets.isEmpty) {
      die();
      return true;
    }
    return _cursor.moveToTarget(target.viewPos).then((_) {
      return enter(inputLoop);
    });
  }

  GamePiece get target => _targets.first;

  dynamic inputLoop(Controller controller) {
    if (_targets.isEmpty) {
      print('no enemies in range');
      return true;
    }
    if (controller.left) {
      var piece = _targets.removeAt(0);
      _targets.add(piece);
      return blockInputUntil(_cursor.moveToTarget(target.viewPos));
    }
    if (controller.right) {
      var piece = _targets.removeLast();
      _targets.insert(0, piece);
      return blockInputUntil(_cursor.moveToTarget(target.viewPos));
    }
    if (controller.action) {
      die();
      return target;
    }
  }

  void onDie() {
    _cursor.die();
  }
}

class DeathAnimation extends Entity {
  Sprite _sprite;
  int _duration;
  int _elapsed = 0;
  int _rotations = 4;
  int _ticksPerDirectionChange;
  var directions = [new Point(-1, 0), new Point(0, -1), new Point(1,0), new Point(0, 1)];

  DeathAnimation(this._sprite, int durationMs) {
    _duration = msToTicks(durationMs);
    _ticksPerDirectionChange = (_duration / (_rotations * 4)).floor();
    _sprite.add(this);
  }

  dynamic run(Controller controller) {
    _elapsed++;
    if (_elapsed == _duration) {
      die();
      return true;
    }
    var dir = directions[_currentFrame % directions.length];
    _sprite.setFacing(dir);
  }

  int get _currentFrame {
    return (_elapsed / _ticksPerDirectionChange).floor();
  }
}
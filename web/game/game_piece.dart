part of tactics;



/**
 * Represents a 'piece' in the game, ie: something that can move and attack in
 * the tactical game.
 */
class GamePiece extends Entity {
  SpriteElement _view;
  Point<int> _pos;
  Map<String, ImageElement> _menuImages;
  GameBoard _board;
  PictureMenuRunner _menuRunner;

  // Valid teams are 0 and 1.
  int _team;
  int _range = 1;

  GamePiece(this._board, SpriteMap spriteMap, this._menuRunner, this._pos, this._team) {
    _view = new SpriteElement(spriteMap, 'down');
    _view.pos = scalePoint(_pos, TILE_WIDTH_PX);
  }
  SpriteElement get view => _view; // TODO remove?
  int get team => _team;
  int get range => _range;
  int get otherTeam => 1 - _team;

  void onInit() {
    addVisual(_view);
  }

  void onDie() {
    removeVisual(_view);
    _view = null;
  }

  Point<int> get viewPos => _view.pos;
  Point<int> get pos => _pos;

  dynamic makeMoveInputLoop(Controller controller) {
    Point<int> delta = controller.direction;
    if (delta != null) {
      _pos += delta;
      _view.setFacing(delta);
      return slideTo(_view, _view.pos, scalePoint(_pos, TILE_WIDTH_PX), 270);
    }

    if (controller.action) {
      var defaultAction = _board.getNearbyPieces(_pos, otherTeam, range).isEmpty ? 'stay' : 'attack';
      return _menuRunner.runMenu(defaultAction).exit((item) {
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

  Exit makeMove() {
    return enter(makeMoveInputLoop);
  }

  Exit kill() {
    return enter(new DeathSpinAnimation(view, 480).run).exit((_) {
      return enter(new LinearAnimation(view, 'explosion', 640).run).exit((_) {
        die();
        return true;
      });
    });
  }

  Exit runAttack() {
    return enter(new ChooseAttackTarget(this, _board).run).exit((GamePiece target) {
      return target.kill().exit((_) {
        view.setFacing(new Point<int>(0, 1));
        return true;
      });
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
    return lookAtTarget().exit((_) {
      return enter(inputLoop);
    });
  }

  Exit lookAtTarget() {
    _piece.view.setFacing(target.pos - _piece.pos);
    return blockInputUntil(_cursor.moveToTarget(target.viewPos));
  }

  Exit moveCursorBackToPlayer() {
    return blockInputUntil(_cursor.moveToTarget(_piece.viewPos));
  }

  GamePiece get target => _targets.first;

  dynamic inputLoop(Controller controller) {
    if (_targets.isEmpty) {
      print('no enemies in range');
      die();
      return true;
    }
    if (controller.left) {
      var piece = _targets.removeAt(0);
      _targets.add(piece);
      return lookAtTarget();
    }
    if (controller.right) {
      var piece = _targets.removeLast();
      _targets.insert(0, piece);
      return lookAtTarget();
    }
    if (controller.action) {
      die();
      return target;
    }
    if (controller.cancel) {
      return moveCursorBackToPlayer().exit((_) {
        die();
        return true;
      });
    }
    return inputLoop;
  }

  void onDie() {
    _cursor.die();
  }
}

class DeathSpinAnimation {
  SpriteElement _sprite;
  int _duration;
  int _elapsed = 0;
  int _rotations = 4;
  double _ticksPerDirectionChange;
  var directions = [new Point(-1, 0), new Point(0, -1), new Point(1, 0), new Point(0, 1)];

  DeathSpinAnimation(this._sprite, int durationMs) {
    _duration = msToTicks(durationMs);
    _ticksPerDirectionChange = _duration / (_rotations * 4);
  }

  dynamic run(Controller controller) {
    _elapsed++;
    if (_elapsed == _duration) {
      return true;
    }
    var dir = directions[_currentFrame % directions.length];
    _sprite.setFacing(dir);
  }

  int get _currentFrame {
    return (_elapsed / _ticksPerDirectionChange).floor();
  }
}

class LinearAnimation {
  SpriteElement _sprite;
  int _duration;
  int _elapsed = 0;
  double _ticksPerFrame;
  int _frameCount;
  String _animationName;

  LinearAnimation(this._sprite, this._animationName, int durationMs) {
    _duration = msToTicks(durationMs);
    _sprite.animation = _animationName;
    _ticksPerFrame = _duration / _sprite.frameCount;
  }

  dynamic run(Controller controller) {
    _elapsed++;
    if (_elapsed >= _duration) {
      return true;
    }
    int frame = min(_sprite.frameCount, (_elapsed / _ticksPerFrame).floor());
    _sprite.animation = _animationName;
    _sprite.frame = frame;
  }
}

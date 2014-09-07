part of tactics;

class GameBoard extends VisualElement {
  List<GamePiece> _pieces = [];
  Map<int, List<GamePiece>> _turnOrder = {};
  GamePiece _currentPiece = null;
  TileMap _tiles;
  List<VisualElement> _highlights = [];

  GameBoard(this._tiles) {
    add(_tiles);
  }

  GamePiece get currentPiece => _currentPiece;
  bool get isGameOver {
    return _turnOrder[0].isEmpty || _turnOrder[1].isEmpty;
  }

  void addPiece(GamePiece piece) {
    if (_currentPiece == null) {
      _currentPiece = piece;
    }
    _pieces.add(piece);
    _turnOrder.putIfAbsent(piece.team, () => []).add(piece);
    piece.onDead.then((_) {
      onPieceDied(piece);
    });
  }

  void onPieceDied(GamePiece piece) {
    _pieces.remove(piece);
    _turnOrder[piece.team].remove(piece);
  }

  void nextTurn() {
    moveToEndOfTurnList(_currentPiece);
    int team = 1 - _currentPiece.team;
    _currentPiece = _turnOrder[team].first;
  }

  void moveToEndOfTurnList(GamePiece piece) {
    var list = _turnOrder[piece.team];
    if (!list.remove(piece)) {
      throw new Exception("$piece should have been in the list");
    }
    list.add(piece);
  }

  List<GamePiece> getNearbyPieces(Point<int> point, int team, int range) {
    return _pieces.where((p) => p.team == team && distance(p.pos, point) <= range).toList();
  }

  List<Point<int>> getPointsInRange(Point<int> point, int range) {
    var costs = new Grid(_tiles.tilesWide, _tiles.tilesHigh, (x, y) => -1);
    var visited = new Grid(_tiles.tilesWide, _tiles.tilesHigh, (x, y) => false);
    var q = [point];

    costs.set(point.x, point.y, 0);

    while (!q.isEmpty) {
      var p = _removeNearestPoint(costs, q);
      var costToHere = costs.get(p.x, p.y);
      assert(costToHere >= 0);
      for (var n in _getNeighbors(p)) {
        var cost = _tiles.getTile(n).movementCost;
        var currentCost = costs.get(n.x, n.y);
        if (currentCost == -1 || currentCost > costToHere + cost) {
          costs.set(n.x, n.y, costToHere + cost);
        }
        if (!visited.get(n.x, n.y) && !q.contains(n)) {
          q.add(n);
        }
      }
      visited.set(p.x, p.y, true);
    }

    var result = [];
    for (var x = 0; x < _tiles.tilesWide; x++) {
      for (var y = 0; y < _tiles.tilesHigh; y++) {
        if (costs.get(x, y) <= range) {
          result.add(new Point(x, y));
        }
      }
    }
    return result;
  }

  List<Point<int>> _getNeighbors(Point<int> p) {
    var up = new Point(0, -1);
    var down = new Point(0, 1);
    var left = new Point(-1, 0);
    var right = new Point(1, 0);
    return [up, down, left, right].map((d) => d + p).where((p) => _tiles.contains(p)).toList();
  }

  Point<int> _removeNearestPoint(Grid<int> costs, List<Point<int>> q) {
    int smallest = costs.get(q.first.x, q.first.y);
    int smallestI = 0;
    for (var i = 0; i < q.length; i++) {
      var cost = costs.get(q[i].x, q[i].y);
      if (cost < smallest) {
        smallestI = i;
        smallest = cost;
      }
    }
    return q.removeAt(smallestI);
  }

  void setHighlighted(Point<int> p) {
    var highlight = new HighlightSquare(p);
    _highlights.add(highlight);
    _tiles.add(highlight);
  }

  void clearHighlighted() {
    for (var h in _highlights) {
      _tiles.remove(h);
    }
    _highlights.clear();
  }

  int distance(Point<int> p1, Point<int> p2) {
    return abs(p1.x - p2.x) + abs(p1.y - p2.y);
  }
}

class HighlightSquare extends VisualElement {
  HighlightSquare(Point<int> p) {
    bounds = new Rectangle(p.x * TILE_WIDTH_PX, p.y * TILE_HEIGHT_PX, TILE_WIDTH_PX, TILE_HEIGHT_PX);
  }

  @override
  void doDraw(CanvasRenderingContext2D context) {
    context.globalAlpha = 0.5;
    context.fillStyle = '#000';
    context.fillRect(0, 0, width, height);
  }
}

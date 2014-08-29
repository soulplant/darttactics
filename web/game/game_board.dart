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

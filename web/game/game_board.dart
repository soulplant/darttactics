part of tactics;

class GameBoard {
  List<GamePiece> _pieces = [];
  Map<int, List<GamePiece>> _turnOrder = {};
  GamePiece _currentPiece = null;

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
      print("Got notification that piece died...");
      onPieceDied(piece);
    });
  }

  void onPieceDied(GamePiece piece) {
    _pieces.remove(piece);
    _turnOrder[piece.team].remove(piece);
  }

  GamePiece nextTurn() {
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

  int distance(Point<int> p1, Point<int> p2) {
    return abs(p1.x - p2.x) + abs(p1.y - p2.y);
  }
}

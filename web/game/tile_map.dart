part of tactics;

class Tile {
  String name;
  int movementCost;
  bool highlighted = false;

  Tile(this.name, this.movementCost);
}

class TileMap extends VisualElement {
  static const GRASS = 'grass';
  static const DIRT = 'dirt';

  static Map<String, Tile> TILES = {
    GRASS: new Tile(GRASS, 1),
    DIRT: new Tile(DIRT, 2),
  };
  int _tilesWide;
  int _tilesHigh;
  SpriteMap _imageMap;
  Function _tiles = (p) => TILES[p.x < 5 ? GRASS : DIRT];

  TileMap(this._tilesWide, this._tilesHigh, this._imageMap);

  Tile getTile(Point<int> p) => _tiles(p);

  void doDraw(CanvasRenderingContext2D context) {
    for (var i = 0; i < _tilesWide; i++) {
      for (var j = 0; j < _tilesHigh; j++) {
        var tile = _tiles(new Point(i, j));
        _imageMap.getAnimation(tile.name)[0].draw(context, i * TILE_WIDTH_PX, j * TILE_HEIGHT_PX);
      }
    }
  }
}

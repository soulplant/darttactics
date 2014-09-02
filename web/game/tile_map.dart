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
  SpriteMap _imageMap;
  Grid<Tile> _tiles;
  int get tilesWide => _tiles.width;
  int get tilesHigh => _tiles.height;

  TileMap(int tilesWide, int tilesHigh, this._imageMap) {
    _tiles = new Grid(tilesWide, tilesHigh, (x, y) => x < 5 ? TILES[GRASS] : TILES[DIRT]);
  }

  Tile getTile(Point<int> p) => _tiles.get(p.x, p.y);

  void doDraw(CanvasRenderingContext2D context) {
    for (var i = 0; i < tilesWide; i++) {
      for (var j = 0; j < tilesHigh; j++) {
        var tile = _tiles.get(i, j);
        _imageMap.getAnimation(tile.name)[0].draw(context, i * TILE_WIDTH_PX, j * TILE_HEIGHT_PX);
      }
    }
  }

  bool contains(Point<int> p) {
    return p.x >= 0 && p.x < tilesWide && p.y >= 0 && p.y < tilesHigh;
  }
}

part of tactics;

class Tile {
  String _name;
  int _movementCost;

  Tile(this._name, this._movementCost);
}

class TileMap extends VisualElement {
  static const GRASS = 'grass';
  static const DIRT = 'dirt';

  var TILES = {
    GRASS: new Tile(GRASS, 1),
    DIRT: new Tile(DIRT, 2),
  };
  int _tilesWide;
  int _tilesHigh;
  SpriteMap _imageMap;
  Function _tiles = (x, y) => x < 5 ? GRASS : DIRT;

  TileMap(this._tilesWide, this._tilesHigh, this._imageMap);

  void doDraw(CanvasRenderingContext2D context) {
    for (var i = 0; i < _tilesWide; i++) {
      for (var j = 0; j < _tilesHigh; j++) {
        _imageMap.getAnimation(_tiles(i, j))[0].draw(context, i * TILE_WIDTH_PX, j * TILE_HEIGHT_PX);
      }
    }
  }
}

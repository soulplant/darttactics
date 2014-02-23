part of tactics;

class TileMap extends VisualElement {
  static const GRASS = 'grass';
  static const DIRT = 'dirt';
  int _tilesWide;
  int _tilesHigh;
  Map _imageMap;
  Function _tiles = (x, y) => x < 5 ? GRASS : DIRT;

  TileMap(this._tilesWide, this._tilesHigh, this._imageMap);

  void doDraw(CanvasRenderingContext2D context) {
    for (var i = 0; i < _tilesWide; i++) {
      for (var j = 0; j < _tilesHigh; j++) {
        context.drawImage(_imageMap[_tiles(i, j)], i * 16, j * 16);
      }
    }
  }
}

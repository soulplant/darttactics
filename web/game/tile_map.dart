part of tactics;

class TileMap {
  static const GRASS = 'grass';
  static const DIRT = 'dirt';
  int _width;
  int _height;
  Map _imageMap;
  Function _tiles = (x, y) => x < 5 ? GRASS : DIRT;

  TileMap(this._width, this._height, this._imageMap);

  void draw(CanvasRenderingContext2D context) {
    for (var i = 0; i < _width; i++) {
      for (var j = 0; j < _height; j++) {
        context.drawImage(_imageMap[_tiles(i, j)], i * 16, j * 16);
      }
    }
  }
}

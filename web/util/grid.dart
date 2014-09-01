library grid;

class Grid<T> {
  int _width;
  int _height;
  Function _default;
  List<T> _values;

  int get width => _width;
  int get height => _height;

  Grid(this._width, this._height, this._default) {
    _values = [];
    for (var i = 0; i < _width * _height; i++) {
      _values.add(_default(i % _width, (i / _width).floor()));
    }
  }

  T get(int x, int y) {
    return _values[y * _width + x];
  }

  T set(int x, int y, T value) {
    _values[y * _width + x] = value;
  }
}

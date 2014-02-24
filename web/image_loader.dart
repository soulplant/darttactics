part of tactics_util;

class ImageLoader {
  int _outstandingLoads = 0;
  List<Function> _listeners = [];
  int _widthPx;
  int _heightPx;

  ImageLoader(this._widthPx, this._heightPx);

  Image loadImage(String filename, [int widthPx = 0, int heightPx = 0]) {
    if (widthPx == 0) {
      widthPx = _widthPx;
    }
    if (heightPx == 0) {
      heightPx = _heightPx;
    }
    _outstandingLoads++;
    var image = new ImageElement(src: filename);
    image.onLoad.first.then(onLoadDone);
    return new Image.fromSize(image, widthPx, heightPx);
  }

  Map<String, Image> loadImages(List<String> names) {
    var result = {};
    for (var name in names) {
      result[name] = loadImage('gfx/' + name + '.png');
    }
    return result;
  }

  List<Image> loadImageList(List<String> names) {
    return names.map((name) => loadImage('gfx/$name.png')).toList();
  }

  void onLoadDone(Event event) {
    _outstandingLoads--;
    if (_outstandingLoads == 0) {
      for (var listener in _listeners) {
        listener();
      }
    }
  }

  Map<String, Image> loadImageMapFromDir(String name) {
    var images = {};
    for (var direction in ['left', 'right', 'up', 'down']) {
      var filename = 'gfx/' + name + '-' + direction[0] + '.png';
      images[direction] = loadImage(filename);
    }
    return images;
  }

  void addListener(Function listener) => _listeners.add(listener);
}
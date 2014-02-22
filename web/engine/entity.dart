part of tactics;

class Entity {
  Entity _parent;
  bool _alive = true;
  bool _inited = false;
  List<Entity> _children = [];
  Completer _completer = new Completer.sync();
  KeyFocusStack<Controller> _focusStack;

  Entity([this._focusStack]);

  void baseTick() {
    var children = [];
    children.addAll(_children);

    children.where((c) => c.alive).forEach((c) => c.baseTick());
    children.clear();

    _children.removeWhere((c) => !c.alive);

    tick();
  }

  void ensureInited() {
    if (_inited) {
      return;
    }
    onInit();
    _inited = true;
  }

  void onInit() {}
  void onDie() {}

  void die() {
    onDie();
    _completer.complete();
    _alive = false;
  }

  void tick() {}

  Entity add(Entity entity) {
    if (_parent == null) {
      addChild(entity);
    } else {
      _parent.add(entity);
    }
    return entity;
  }

  void remove(Entity entity) {
    if (_parent == null) {
      removeChild(entity);
    } else {
      _parent.remove(entity);
    }
  }

  void draw(CanvasRenderingContext2D context) {
    _children.forEach((c) => c.draw(context));
  }

  void addChild(Entity entity) {
    if (entity._parent != null) {
      throw new Exception("parent should be null when added");
    }
    _children.add(entity);
    entity._parent = this;
    entity.ensureInited();
  }

  void removeChild(Entity entity) {
    _children.remove(entity);
    entity._parent = null;
  }

  KeyFocusStack<Controller> getFocusStack() {
    if (_parent != null) {
      return _parent.getFocusStack();
    }
    return _focusStack;
  }

  Exit blockUntilDead(Entity e) {
    add(e);
    return blockInputUntil(e.onDead);
  }

  Exit enter(f(Controller controller)) => getFocusStack().enter(f);
  Exit blockInputUntil(Future f) => getFocusStack().blockInputUntil(f);

  bool get alive => _alive;
  Future get onDead => _completer.future;
}

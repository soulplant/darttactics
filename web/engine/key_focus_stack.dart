part of tactics;

class InputHandlerWrapper {
  KeyFocusHandler handler;
  bool gotFirstInput = false;
  Completer completer = new Completer();
  InputHandlerWrapper(this.handler) {}
}

class KeyFocusStack {
  List<InputHandlerWrapper> _stack = [];

  Future push(KeyFocusHandler handler) {
    var wrapper = new InputHandlerWrapper(handler);
    _stack.add(wrapper);
    return wrapper.completer.future;
  }

  void pop() {
    _stack.removeLast().completer.complete();
  }

  KeyFocusHandler get top {
    if (_stack.isEmpty) {
      return null;
    }
    return _stack.last.handler;
  }

  Future blockInputWhile(Future future) {
    push(new InputBlocker());
    return future.then((_) => pop());
  }

  Function block(Function callback) {
    push(new InputBlocker());
    return () {
      pop();
      if (callback != null)
        callback();
    };
  }

  void inputUpdated(Controller controller) {
    if (_stack.isEmpty) {
      return;
    }
    var entry = _stack.last;
    if (!entry.gotFirstInput) {
      entry.gotFirstInput = true;
      entry.handler.onFirstInput();
      // The handler's onFirstInput() might have pushed, so we recur.
      inputUpdated(controller);
      return;
    }

    if (entry.handler.inputUpdated(controller)) {
      pop();
    }
  }
}

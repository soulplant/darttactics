part of tactics;

// TODO: This should be called FrameWrapper, and the Function should be a Frame class.
class Frame {
  Completer completer;
  Function function;
  Frame(this.completer, this.function);
}

// TODO: Rename to FrameStack.
class KeyFocusStack<T> {
  List<Frame> stack = [];

  KeyFocusStack() {
    // Top level frame ignores all input and loops forever.
    enter((input) => null);
  }

  Future enter(Function next) {
    var w = new Frame(new Completer.sync(), next);
    stack.add(w);
    return w.completer.future;
  }

  void _exit(result) {
    Frame w = stack.removeLast();
    w.completer.complete(result);
  }

  void inputUpdated(T input) {
    if (stack.isEmpty) {
      throw new Exception("stack is empty");
    }

    var result = stack.last.function(input);
    _handleResult(result);
  }

  void _handleResult(result) {
    if (result is Future) {
      Future f = result;
      f.then(_handleResult);
    } else if (result is Function) {
      stack.last.function = result;
    } else if (result != null) {
      _exit(result);
    }
  }

  Future blockInputUntil(Future future) {
    future.then((_) => _exit(null));
    return enter((input) => null);
  }
}

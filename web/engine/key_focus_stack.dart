part of tactics;

class Frame {
  Exit exit;
  Function function;

  Frame(this.exit, this.function) {
  }
}

class Exit<T> {
  var _currentResult;
  bool _done = false;
  List<Function> nexts = [];

  void complete(result) {
    if (nexts.isEmpty) {
      if (_done) {
        throw new Exception("completed more than once");
      }
      _done = true;
      _currentResult = result;
      return;
    }
    var r = nexts.removeAt(0)(result);
    if (r is Exit) {
      r.exit(complete);
    } else if (r is Future) {
      throw new Exception("don't mix Futures and Exits");
    } else {
      complete(r);
    }
  }

  Exit<T> exit(f(T result)) {
    if (_done) {
      _currentResult = f(_currentResult);
      return this;
    }
    nexts.add(f);
    return this;
  }
}

// TODO: Rename to FrameStack.
class KeyFocusStack<T> {
  List<Frame> stack = [];

  KeyFocusStack() {
    // Top level frame ignores all input and loops forever.
    enter((input) => null);
  }

  Exit enter(next(T input)) {
    var frame = new Frame(new Exit(), next);
    stack.add(frame);
    return frame.exit;
  }

  void _exit(result) {
    Frame frame = stack.removeLast();
    frame.exit.complete(result);
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
      throw new Exception("Don't mix Futures and Exits");
    } else if (result is Exit) {
      Exit f = result;
      f.exit(_handleResult);
    } else if (result is Function) {
      stack.last.function = result;
    } else if (result != null) {
      _exit(result);
    }
  }

  Exit blockInputUntil(Future future) {
    future.then((_) => _exit(null));
    return enter((input) => null);
  }
}

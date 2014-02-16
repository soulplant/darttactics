part of tactics;

abstract class KeyFocusHandler {
  void onFirstInput() {}
  bool inputUpdated(Controller controller);
}

class InputBlocker extends KeyFocusHandler {
  bool inputUpdated(Controller controller) => false;
}
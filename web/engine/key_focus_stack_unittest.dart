library key_focus_stack_test;

import 'dart:async';
import 'package:unittest/unittest.dart';

import '../tactics.dart';

main() {
  group('KeyFocusStack tests', () {
    KeyFocusStack<String> focusStack;
    setUp(() {
      focusStack = new KeyFocusStack<String>();
    });

    test("enter", () {
      handleInput(String s) {
        if (s == 'done') {
          return 5;
        }
      }
      var c = new Controller();
      bool gotToHere = false;
      focusStack.enter(handleInput).exit((x) {
        expect(x, equals(5));
        gotToHere = true;
      });
      focusStack.inputUpdated('notdone');
      expect(gotToHere, equals(false));

      focusStack.inputUpdated('done');
      expect(gotToHere, equals(true));
    });

    test("nested enters", () {
      int gotToHere = 0;
      focusStack.enter((_) {
        gotToHere = 1;
        return focusStack.enter((s) {
          gotToHere = 2;
          return focusStack.enter((s) {
            gotToHere = 3;
            return 'hi';
          });
        }).exit((x) {
          expect(x, equals('hi'));
          return (c) {
            gotToHere = 4;
            return 15;
          };
        });
      }).exit((x) {
        gotToHere = 5;
        expect(x, equals(15));
        return focusStack.enter((s) {
          gotToHere = 6;
        });
      });
      expect(gotToHere, equals(0));
      focusStack.inputUpdated("");
      expect(gotToHere, equals(1));
      focusStack.inputUpdated("");
      expect(gotToHere, equals(2));
      focusStack.inputUpdated("");
      expect(gotToHere, equals(3));
      focusStack.inputUpdated("");
      expect(gotToHere, equals(5));
      focusStack.inputUpdated("");
      expect(gotToHere, equals(6));
    });

    test('exit chaining', () {
      int gotToHere = 0;
      focusStack.enter((_) => 'first').exit((_) =>
          focusStack.enter((_) => 'second').exit((second) =>
              focusStack.enter((_) => 'third').exit((result) {
                expect(result, equals('third'));
                expect(second, equals('second'));
                gotToHere = 1;
                return focusStack.enter((_) => 'asdf');
              }))).exit((r) {
                expect(r, equals('asdf'));
                gotToHere = 2;
              });
      focusStack.inputUpdated("");
      focusStack.inputUpdated("");
      focusStack.inputUpdated("");
      expect(gotToHere, equals(1));
      focusStack.inputUpdated("");
      expect(gotToHere, equals(2));
    });

    test('block input while', () {
      var completer = new Completer.sync();
      String lastRunWith = null;
      focusStack.enter((str) {
        lastRunWith = str;
        if (str == 'block')
          return focusStack.blockInputUntil(completer.future);
      });
      expect(lastRunWith, equals(null));
      focusStack.inputUpdated('hi');
      expect(lastRunWith, equals('hi'));
      focusStack.inputUpdated('block');
      focusStack.inputUpdated('should be ignored');
      expect(lastRunWith, equals('block'));
      completer.complete();
      focusStack.inputUpdated('should go through again');
      expect(lastRunWith, equals('should go through again'));
    });
  });
}
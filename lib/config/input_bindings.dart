import 'package:flutter/services.dart';

/// Keyboard bindings for player actions.
/// Centralized so controls aren't hard-coded in components.
/// Not user-editable yet — the class is immutable and exposes
/// `defaultBindings` for now; later we can persist and let players
/// edit these at runtime.
class InputBindings {
  final Set<LogicalKeyboardKey> up;
  final Set<LogicalKeyboardKey> down;
  final Set<LogicalKeyboardKey> left;
  final Set<LogicalKeyboardKey> right;
  final Set<LogicalKeyboardKey> dash;
  final Set<LogicalKeyboardKey> reset;

  InputBindings({
    Set<LogicalKeyboardKey>? up,
    Set<LogicalKeyboardKey>? down,
    Set<LogicalKeyboardKey>? left,
    Set<LogicalKeyboardKey>? right,
    Set<LogicalKeyboardKey>? dash,
    Set<LogicalKeyboardKey>? reset,
  }) : up = up ?? {LogicalKeyboardKey.keyW, LogicalKeyboardKey.arrowUp},
       down = down ?? {LogicalKeyboardKey.keyS, LogicalKeyboardKey.arrowDown},
       left = left ?? {LogicalKeyboardKey.keyA, LogicalKeyboardKey.arrowLeft},
       right =
           right ?? {LogicalKeyboardKey.keyD, LogicalKeyboardKey.arrowRight},
       dash = dash ?? {LogicalKeyboardKey.space},
       reset = reset ?? {LogicalKeyboardKey.keyR};

  static final InputBindings defaultBindings = InputBindings();

  /// Returns true if any key from [actionKeys] is currently pressed (in [pressedKeys]).
  bool isActionPressed(
    Set<LogicalKeyboardKey> pressedKeys,
    Set<LogicalKeyboardKey> actionKeys,
  ) {
    return pressedKeys.intersection(actionKeys).isNotEmpty;
  }
}

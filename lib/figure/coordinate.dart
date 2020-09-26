import 'package:flutter/cupertino.dart';

class Coordinate {
  int _x;
  int _y;

  Coordinate({@required x, @required int y}) {
    _x = x;
    _y = y;
  }

  int get x => _x;

  int get y => _y;

  bool isVisible() {
    return y >= 0;
  }

  void moveDown() {
    _y += 1;
  }

  void moveLeft() {
    _x -= 1;
  }

  void moveRight() {
    _x += 1;
  }

  int getCurrentPosition() {
    return y * 10 + x;
  }

  int getSidewaysPosition(int step) {
    return (y * 10) + x + step;
  }

  int getMoveDownPosition() {
    return (y + 1) * 10 + x;
  }

  Coordinate getMoveDownCoordinate() {
    return Coordinate(y: y + 1, x: x);
  }

  Coordinate getSidewaysStepCoordinate(int step) {
    return Coordinate(y: y, x: x + step);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coordinate &&
          runtimeType == other.runtimeType &&
          _x == other._x &&
          _y == other._y;

  @override
  int get hashCode => _x.hashCode ^ _y.hashCode;

  @override
  String toString() {
    return 'Coordinate{_x: $_x, _y: $_y}';
  }

  void moveTo(int xNew, int yNew) {
    _x = xNew;
    _y = yNew;
  }
}

import 'dart:math';

import 'package:tetris/figure/coordinate.dart';
import 'package:tetris/figure/figure_type.dart';

import 'figure.dart';

class FigureCreator {
  static final figureMap = {
    0: FigureType.LONG_STICK,
    1: FigureType.T,
    2: FigureType.L,
    3: FigureType.INVERTED_L,
    4: FigureType.Z,
    5: FigureType.INVERTED_Z,
    6: FigureType.SQUARE,
  };

  static Figure getNewFigure() {
    Random random = new Random();
    var randomNr = random.nextInt(7);
    var figureType = figureMap[randomNr];
    return Figure(_getFigure(figureType), figureType);
  }

  static List<Coordinate> _getFigure(FigureType figureType) {
    var result;
    switch (figureType) {
      case FigureType.LONG_STICK:
        result = [
          Coordinate(x: 5, y: -4),
          Coordinate(x: 5, y: -3),
          Coordinate(x: 5, y: -2),
          Coordinate(x: 5, y: -1),
        ];
        break;
      case FigureType.L:
        result = [
          Coordinate(x: 5, y: -3),
          Coordinate(x: 5, y: -2),
          Coordinate(x: 5, y: -1),
          Coordinate(x: 6, y: -1),
        ];
        break;
      case FigureType.INVERTED_L:
        result = [
          Coordinate(x: 5, y: -3),
          Coordinate(x: 5, y: -2),
          Coordinate(x: 5, y: -1),
          Coordinate(x: 4, y: -1),
        ];
        break;
      case FigureType.Z:
        result = [
          Coordinate(x: 4, y: -2),
          Coordinate(x: 5, y: -2),
          Coordinate(x: 5, y: -1),
          Coordinate(x: 6, y: -1),
        ];
        break;
      case FigureType.INVERTED_Z:
        result = [
          Coordinate(x: 6, y: -2),
          Coordinate(x: 5, y: -2),
          Coordinate(x: 5, y: -1),
          Coordinate(x: 4, y: -1),
        ];
        break;
      case FigureType.T:
        result = [
          Coordinate(x: 5, y: -3),
          Coordinate(x: 5, y: -2),
          Coordinate(x: 6, y: -2),
          Coordinate(x: 5, y: -1),
        ];
        break;
      case FigureType.SQUARE:
        result = [
          Coordinate(x: 5, y: -2),
          Coordinate(x: 6, y: -2),
          Coordinate(x: 5, y: -1),
          Coordinate(x: 6, y: -1),
        ];
        break;
    }
    return result;
  }
}

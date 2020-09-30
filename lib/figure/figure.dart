import 'package:tetris/figure/coordinate.dart';
import 'package:tetris/figure/figure_type.dart';

class Figure {
  final List<Coordinate> _coordinates;
  final FigureType _type;

  Figure(this._coordinates, this._type);

  FigureType get type => _type;

  List<Coordinate> get coordinates => _coordinates;

  bool hasMultipleOn(Coordinate coordinate) {
    var predicateResult = coordinates.where((element) => element == coordinate);
    return predicateResult.length > 1;
  }

  bool hasOtherOn(Coordinate coordinate) {
   return coordinates.where((element) => element == coordinate).length == 1;
  }

  bool isOnGameScreen() {
    return coordinates.any((element) => element.y > 0);
  }

  @override
  String toString() {
    return 'Figure{_coordinates: $_coordinates, _type: $_type}';
  }
}
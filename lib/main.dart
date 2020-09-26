import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/figure/figure_creator.dart';
import 'package:tetris/tetris_block.dart';

import 'figure/coordinate.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final gameScreen = List.generate(10 * 20, (index) => TetrisBlock());
  var activeFigure = FigureCreator.getNewFigure();

  _MyHomePageState() {
    startTimer();
  }

  void startTimer() {
    Timer.periodic(new Duration(seconds: 1), (timer) {
      moveDown();
    });
  }

  void moveDown() {
    var canMove = true;
    for (var coordinate in activeFigure.coordinates) {
      var nexPos = coordinate.getMoveDownPosition();
      if (coordinate.isVisible()) {
        if (nexPos > 199) {
          canMove = false;
          activeFigure = FigureCreator.getNewFigure();
          break;
        }
        var block = gameScreen[nexPos];
        if (block.isFilled() &&
            !activeFigure.hasOtherOn(coordinate.getMoveDownCoordinate())) {
          activeFigure = FigureCreator.getNewFigure();
          canMove = false;
          break;
        }
      }
    }

    if (canMove) {
      activeFigure.coordinates.forEach((coordinate) {
        var nextPos = coordinate.getMoveDownPosition();
        if (coordinate.isVisible() && !activeFigure.hasMultipleOn(coordinate)) {
          gameScreen[coordinate.getCurrentPosition()].clear();
        }
        coordinate.moveDown();

        if (coordinate.isVisible()) {
          if (!activeFigure.hasMultipleOn(coordinate)) {
            gameScreen[coordinate.getCurrentPosition()].clear();
          }
          var block = gameScreen[nextPos];
          block.setFilled();
        }
      });
    }
  }

  void moveSideways(int step) {
    var canMove = true;
    for (var coordinate in activeFigure.coordinates) {
      var newX = coordinate.x + step;
      if (newX > 9 || newX < 0) {
        canMove = false;
        break;
      }
      if (coordinate.isVisible()) {
        var newPosition = coordinate.getSidewaysPosition(step);
        var block = gameScreen[newPosition];
        if (block.isFilled() &&
            !activeFigure
                .hasOtherOn(coordinate.getSidewaysStepCoordinate(step))) {
          canMove = false;
        }
      }
    }
    print('can move $canMove');
    if (canMove) {
      activeFigure.coordinates.forEach((coordinate) {
        var nextPos = coordinate.getSidewaysPosition(step);
        if (coordinate.isVisible() && !activeFigure.hasMultipleOn(coordinate)) {
          gameScreen[coordinate.getCurrentPosition()].clear();
        }

        if (step == -1) {
          coordinate.moveLeft();
        } else {
          coordinate.moveRight();
        }

        if (coordinate.isVisible()) {
          if (!activeFigure.hasMultipleOn(coordinate)) {
            gameScreen[coordinate.getCurrentPosition()].clear();
          }
          gameScreen[nextPos].setFilled();
        }
      });
    }
  }

  void rotate() {
    var maxY = activeFigure.coordinates.map((e) => e.y).reduce(max);
    var minX = activeFigure.coordinates.map((e) => e.x).reduce(min);
    var canTurn = true;

    activeFigure.coordinates.forEach((coordinate) {
      var oldX = coordinate.x;
      var oldY = coordinate.y;
      var yNew = oldX + (maxY - minX);
      var xNew = minX + (maxY - oldY);
      if (minX >= 0 && yNew < 20 && xNew <= 9) {
        var pos = (yNew * 10) + xNew;
        if(!activeFigure.hasOtherOn(new Coordinate(x: xNew, y: yNew))) {
          canTurn = !gameScreen[pos].isFilled();
          print('can turn $canTurn');
        }
      } else {
        canTurn = false;
      }
    });

    if(canTurn) {
      activeFigure.coordinates.forEach((coordinate) {

        if(coordinate.isVisible() && !activeFigure.hasMultipleOn(coordinate)) {
          gameScreen[coordinate.getCurrentPosition()].clear();
        }

        var oldX = coordinate.x;
        var oldY = coordinate.y;
        var yNew = oldX + (maxY - minX);
        var xNew = minX + (maxY - oldY);
        coordinate.moveTo(xNew, yNew);

        if(coordinate.isVisible()) {
          gameScreen[coordinate.getCurrentPosition()].setFilled();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: 80),
            ),
            Container(
              constraints:
                  BoxConstraints(minWidth: 100, maxWidth: 250, maxHeight: 500),
              child: GridView.count(
                crossAxisCount: 10,
                childAspectRatio: 1.0,
                padding: const EdgeInsets.all(2.0),
                mainAxisSpacing: 2.0,
                crossAxisSpacing: 2.0,
                children: gameScreen,
              ),
            ),
            new ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ButtonTheme(
                  minWidth: 40.0,
                  height: 40.0,
                  child: RaisedButton(
                    onPressed: () => moveSideways(-1),
                    child: Icon(
                      Icons.chevron_left,
                      size: 50,
                    ),
                  ),
                ),
                ButtonTheme(
                  minWidth: 40.0,
                  height: 40.0,
                  child: RaisedButton(
                    onPressed: () => moveDown(),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 50,
                    ),
                  ),
                ),
                ButtonTheme(
                  minWidth: 40.0,
                  height: 40.0,
                  child: RaisedButton(
                    onPressed: () => rotate(),
                    child: Icon(
                      Icons.refresh,
                      size: 50,
                    ),
                  ),
                ),
                ButtonTheme(
                  minWidth: 40.0,
                  height: 40.0,
                  child: RaisedButton(
                    onPressed: () => moveSideways(1),
                    child: Icon(
                      Icons.chevron_right,
                      size: 50,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

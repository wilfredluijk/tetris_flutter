import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/figure/figure_creator.dart';
import 'package:tetris/tetris_block.dart';

import 'figure/coordinate.dart';
import 'figure/figure.dart';

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
  final gameScreen = List.generate(10 * 20, (index) => false);
  Figure stagingFigure;
  var activeFigure = FigureCreator.getNewFigure();

  var pause = false;
  var loseGame = false;

  var level = 1;
  var lines = 0;
  var score = 0;

  _MyHomePageState() {
    startTimer();
  }

  void startTimer() {
    stagingFigure = FigureCreator.getNewFigure();
    Timer.periodic(new Duration(seconds: 1), (timer) {
      if (!pause) {
        moveDown();
      }
    });
  }

  void restartGame() {
    this.loseGame = false;
    this.pause = false;
  }

  void resetActiveFigure() {
    scoreForCompletedRows();
    if (activeFigure.isOnGameScreen()) {
      print('figure is on game screen $activeFigure');
      activeFigure = stagingFigure;
      stagingFigure = FigureCreator.getNewFigure();
    } else {
      this.loseGame = true;
      this.pause = true;
      setState(() {
        level = 1;
        lines = 0;
        score = 0;
      });
      fillScreenSequence();
    }
  }

  void clearGameScreenSequence() {
    for (int i = 0; i <= 19; i++) {
      var startIndex = i * 10;
      var endIndex = startIndex + 9;
      var delay = i * 50;
      new Future.delayed(Duration(milliseconds: delay), () {
        for (int j = startIndex; j <= endIndex; j++) {
          setState(() {
            print('in loop clear $j');
            gameScreen[j] = false;
          });

          if (i == 19) {
            new Future.delayed(const Duration(milliseconds: 1000), () {
              restartGame();
            });
          }
        }
      });
    }
  }

  void fillScreenSequence() {
    for (int i = 19; i >= 0; i--) {
      var startIndex = i * 10;
      var endIndex = startIndex + 9;
      var delay = 50 * (20 - i);

      new Future.delayed(Duration(milliseconds: delay), () {
        for (int j = startIndex; j <= endIndex; j++) {
          setState(() {
            print('in loop fill $j');
            gameScreen[j] = true;

            if (i == 0) {
              new Future.delayed(const Duration(milliseconds: 400), () {
                clearGameScreenSequence();
              });
            }
          });
        }
      });
    }
  }

  void scoreForCompletedRows() {
    var lineCount = 0;

    for (int i = 0; i <= 19; i++) {
      var startIndex = i * 10;
      var endIndex = startIndex + 9;
      var scoreAbleLine = true;
      for (int j = startIndex; j <= endIndex; j++) {
        if (!gameScreen[j]) {
          scoreAbleLine = false;
          break;
        }
      }

      if (scoreAbleLine) {
        setState(() {
          lineCount++;
          gameScreen.removeRange(startIndex, endIndex);
          for (int j = 0; j < 10; j++) {
            gameScreen.insert(j, false);
          }
        });
      }
    }

    var tmpScore = 0;
    if (lineCount > 0) {
      var tmpLevel = getLevel();
      switch (lineCount) {
        case 1:
          tmpScore += (tmpLevel * 100);
          break;
        case 2:
          tmpScore += (tmpLevel * 200);
          break;
        case 3:
          tmpScore += (tmpLevel * 500);
          break;
        case 4:
          tmpScore += (tmpLevel * 800);
          break;
      }
      setState(() {
        lines += lineCount;
        score += tmpScore;
        level = tmpLevel;
      });
    }
  }

  void moveDown() {
    var canMove = true;
    for (var coordinate in activeFigure.coordinates) {
      var nexPos = coordinate.getMoveDownPosition();
      if (coordinate.isVisible()) {
        if (nexPos > 199) {
          canMove = false;
          resetActiveFigure();
          break;
        }
        if (gameScreen[nexPos] &&
            !activeFigure.hasOtherOn(coordinate.getMoveDownCoordinate())) {
          resetActiveFigure();
          canMove = false;
          break;
        }
      }
    }

    if (canMove) {
      activeFigure.coordinates.forEach((coordinate) {
        var nextPos = coordinate.getMoveDownPosition();
        if (coordinate.isVisible() && !activeFigure.hasMultipleOn(coordinate)) {
          clearPosition(coordinate.getCurrentPosition());
        }
        coordinate.moveDown();

        if (coordinate.isVisible()) {
          if (!activeFigure.hasMultipleOn(coordinate)) {
            clearPosition(coordinate.getCurrentPosition());
          }
          setPositionFilled(nextPos);
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
        if (gameScreen[newPosition] &&
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
          clearPosition(coordinate.getCurrentPosition());
        }

        if (step == -1) {
          coordinate.moveLeft();
        } else {
          coordinate.moveRight();
        }

        if (coordinate.isVisible()) {
          if (!activeFigure.hasMultipleOn(coordinate)) {
            clearPosition(coordinate.getCurrentPosition());
          }
          setPositionFilled(nextPos);
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
        if (!activeFigure.hasOtherOn(new Coordinate(x: xNew, y: yNew))) {
          canTurn = !gameScreen[pos];
          print('can turn $canTurn');
        }
      } else {
        canTurn = false;
      }
    });

    if (canTurn) {
      activeFigure.coordinates.forEach((coordinate) {
        if (coordinate.isVisible() && !activeFigure.hasMultipleOn(coordinate)) {
          clearPosition(coordinate.getCurrentPosition());
        }

        var oldX = coordinate.x;
        var oldY = coordinate.y;
        var yNew = oldX + (maxY - minX);
        var xNew = minX + (maxY - oldY);
        coordinate.moveTo(xNew, yNew);

        if (coordinate.isVisible()) {
          setPositionFilled(coordinate.getCurrentPosition());
        }
      });
    }
  }

  clearPosition(int location) {
    setState(() {
      gameScreen[location] = false;
    });
  }

  setPositionFilled(int location) {
    setState(() {
      gameScreen[location] = true;
    });
  }

  getLevel() {
    var level = 1;
    if (lines > 10) {
      level = (lines / 10).round();
    }
    return level;
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('level: $level'),
                Text('lines: $lines'),
                Text('score: $score'),
              ],
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
                children: gameScreen.map((e) => TetrisBlock(e)).toList(),
              ),
            ),
            new ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ButtonTheme(
                  minWidth: 40.0,
                  height: 40.0,
                  child: RaisedButton(
                    onPressed: () => {
                      if (!pause) {moveSideways(-1)}
                    },
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
                    onPressed: () => {
                      if (!pause) {moveDown()}
                    },
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
                    onPressed: () => {
                      if (!pause) {rotate()}
                    },
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
                    onPressed: () => {
                      if (!pause) {moveSideways(1)}
                    },
                    child: Icon(
                      Icons.chevron_right,
                      size: 50,
                    ),
                  ),
                ),
              ],
            ),
            new ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ButtonTheme(
                  minWidth: 40.0,
                  height: 40.0,
                  child: RaisedButton(
                    onPressed: () => {
                      if (!loseGame) {pause = !pause}
                    },
                    child: Icon(
                      Icons.pause,
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

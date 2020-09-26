import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TetrisBlock extends StatefulWidget {

  final state = _TetrisBlockState();

  @override
  State<StatefulWidget> createState() => state;

  bool isFilled() {
    return state._isFilled;
  }

  void setFilled() {
      state.fill();
  }

  void clear() {
    state.clear();
  }
}

class _TetrisBlockState extends State<TetrisBlock> {

  bool _isFilled = false;

  var box = new SizedBox(
      width: 5,
      height: 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black54,
          border: Border.all(color: Colors.black),
        ),
      ),
  );

  @override
  Widget build(BuildContext context) {
    return box;
  }

  void fill() {
    _isFilled = true;
    setState(() {
      box = new SizedBox(
        width: 5,
        height: 5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border.all(color: Colors.black),
          ),
        ),
      );
    });
  }

  void clear() {
    _isFilled = false;
    setState(() {
      box = new SizedBox(
        width: 5,
        height: 5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black54,
            border: Border.all(color: Colors.black),
          ),
        ),
      );
    });
  }
}
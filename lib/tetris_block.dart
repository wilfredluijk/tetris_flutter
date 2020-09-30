import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TetrisBlock extends StatelessWidget {
  final filled;

  TetrisBlock(this.filled);

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      width: 5,
      height: 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: filled ? Colors.green : Colors.black54,
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }

}

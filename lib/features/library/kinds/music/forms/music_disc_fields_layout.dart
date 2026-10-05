import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reference disc strip: flexible title, 200px storage, 65px slot, 150px matrices.
class MusicDiscFieldsLayout extends StatelessWidget {
  const MusicDiscFieldsLayout(
      {super.key,
      required this.title,
      required this.storage,
      required this.slot,
      required this.matrixA,
      required this.matrixB});
  final Widget title, storage, slot, matrixA, matrixB;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Wrap(spacing: 10, runSpacing: 12, children: [
          SizedBox(width: width >= 805 ? width - 605 : width, child: title),
          SizedBox(width: math.min(200, width), child: storage),
          SizedBox(width: math.min(65, width), child: slot),
          SizedBox(width: math.min(150, width), child: matrixA),
          SizedBox(width: math.min(150, width), child: matrixB),
        ]);
      });
}

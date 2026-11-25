import 'package:flutter/material.dart';

enum Direction { up, down, left, right }

class GridPoint {
  final int r;
  final int c;
  
  GridPoint(this.r, this.c);

  // We override equality so Dart knows when two grid points are the exact same cell
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPoint && runtimeType == other.runtimeType && r == other.r && c == other.c;

  @override
  int get hashCode => r.hashCode ^ c.hashCode;
}

class PathEntity {
  final int id;
  List<GridPoint> segments; // segments.first is the head (arrow), segments.last is the tail
  final Direction escapeDirection;
  final Color color;
  bool isEscaped;

  PathEntity({
    required this.id,
    required this.segments,
    required this.escapeDirection,
    required this.color,
    this.isEscaped = false,
  });
}
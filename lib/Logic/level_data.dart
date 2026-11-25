import 'package:flutter/material.dart';

import 'game_logic.dart';

class LevelConfig {
  final int levelNumber;
  final int rows;
  final int cols;
  final List<GridTileData> tiles;
  final Color primaryGlowColor;
  final Color secondaryGlowColor;
  final String levelTitle;

  LevelConfig({
    required this.levelNumber,
    required this.rows,
    required this.cols,
    required this.tiles,
    required this.primaryGlowColor,
    required this.secondaryGlowColor,
    required this.levelTitle,
  });
}

class GridTileData {
  final int row;
  final int col;
  final TileType type;
  final Direction? direction;

  GridTileData({
    required this.row,
    required this.col,
    required this.type,
    this.direction,
  });
}

class LevelRepository {
  static List<LevelConfig> getLevels() {
    return [
      // Level 1: 3x3 Beginner Intro (Cyan / Indigo Accent)
      LevelConfig(
        levelNumber: 1,
        rows: 3,
        cols: 3,
        levelTitle: "CYBER IGNITION",
        primaryGlowColor: const Color(0xFF38BDF8),
        secondaryGlowColor: const Color(0xFF818CF8),
        tiles: [
          GridTileData(
            row: 1,
            col: 0,
            type: TileType.arrow,
            direction: Direction.right,
          ),
          GridTileData(
            row: 1,
            col: 1,
            type: TileType.arrow,
            direction: Direction.up,
          ),
          GridTileData(
            row: 2,
            col: 1,
            type: TileType.arrow,
            direction: Direction.down,
          ),
        ],
      ),

      // Level 2: 4x4 Neon Spectrum (Rose / Amber Accent)
      LevelConfig(
        levelNumber: 2,
        rows: 4,
        cols: 4,
        levelTitle: "NEON CROSSING",
        primaryGlowColor: const Color(0xFFF43F5E),
        secondaryGlowColor: const Color(0xFFFB923C),
        tiles: [
          GridTileData(
            row: 0,
            col: 1,
            type: TileType.arrow,
            direction: Direction.down,
          ),
          GridTileData(
            row: 1,
            col: 1,
            type: TileType.arrow,
            direction: Direction.right,
          ),
          GridTileData(
            row: 2,
            col: 2,
            type: TileType.arrow,
            direction: Direction.up,
          ),
          GridTileData(
            row: 2,
            col: 0,
            type: TileType.arrow,
            direction: Direction.right,
          ),
        ],
      ),

      // Level 3: 5x5 Matrix Lock (Emerald / Cyan Accent)
      LevelConfig(
        levelNumber: 3,
        rows: 5,
        cols: 5,
        levelTitle: "EMERALD MATRIX",
        primaryGlowColor: const Color(0xFF10B981),
        secondaryGlowColor: const Color(0xFF06B6D4),
        tiles: [
          GridTileData(
            row: 2,
            col: 2,
            type: TileType.arrow,
            direction: Direction.up,
          ),
          GridTileData(
            row: 2,
            col: 1,
            type: TileType.arrow,
            direction: Direction.right,
          ),
          GridTileData(
            row: 1,
            col: 2,
            type: TileType.arrow,
            direction: Direction.right,
          ),
          GridTileData(
            row: 4,
            col: 3,
            type: TileType.arrow,
            direction: Direction.up,
          ),
          GridTileData(
            row: 0,
            col: 3,
            type: TileType.arrow,
            direction: Direction.left,
          ),
        ],
      ),

      // Level 4: 5x5 Violet Prism (Purple / Magenta Accent) - SOLVED DEADLOCK
      LevelConfig(
        levelNumber: 4,
        rows: 5,
        cols: 5,
        levelTitle: "VIOLET ECLIPSE",
        primaryGlowColor: const Color(0xFFA855F7),
        secondaryGlowColor: const Color(0xFFEC4899),
        tiles: [
          GridTileData(
            row: 0,
            col: 0,
            type: TileType.arrow,
            direction: Direction.right,
          ),
          GridTileData(
            row: 0,
            col: 2,
            type: TileType.arrow,
            direction: Direction.down,
          ),
          GridTileData(
            row: 2,
            col: 2,
            type: TileType.arrow,
            direction: Direction.right,
          ),
          // FIX: Changed direction from Up to Down to prevent deadlock
          GridTileData(
            row: 4,
            col: 2,
            type: TileType.arrow,
            direction: Direction.down,
          ),
          GridTileData(
            row: 3,
            col: 4,
            type: TileType.arrow,
            direction: Direction.left,
          ),
        ],
      ),
    ];
  }
}

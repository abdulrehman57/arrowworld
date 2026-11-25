// import 'level_data.dart';

// enum Direction { up, down, left, right }

// enum TileType { empty, arrow, prism, portal, wall }

// class GridTile {
//   final int row;
//   final int col;
//   TileType type;
//   Direction? direction;
//   bool isEscaped;

//   GridTile({
//     required this.row,
//     required this.col,
//     this.type = TileType.empty,
//     this.direction,
//     this.isEscaped = false,
//   });
// }

// class GameEngine {
//   int rows = 3;
//   int cols = 3;
//   late List<List<GridTile>> board;
//   int movesCount = 0;
//   int currentLevelIndex = 0;
//   late LevelConfig currentConfig;

//   GameEngine() {
//     loadLevel(0);
//   }

//   void loadLevel(int levelIndex) {
//     final levels = LevelRepository.getLevels();
//     if (levelIndex >= levels.length) {
//       currentLevelIndex = 0; // Loop back to level 1 when finished
//     } else {
//       currentLevelIndex = levelIndex;
//     }

//     currentConfig = levels[currentLevelIndex];
//     rows = currentConfig.rows;
//     cols = currentConfig.cols;
//     movesCount = 0;

//     _initBoard();

//     for (var tileData in currentConfig.tiles) {
//       board[tileData.row][tileData.col] = GridTile(
//         row: tileData.row,
//         col: tileData.col,
//         type: tileData.type,
//         direction: tileData.direction,
//       );
//     }
//   }

//   void nextLevel() {
//     loadLevel(currentLevelIndex + 1);
//   }

//   void resetCurrentLevel() {
//     loadLevel(currentLevelIndex);
//   }

//   void _initBoard() {
//     board = List.generate(
//       rows,
//       (r) => List.generate(cols, (c) => GridTile(row: r, col: c)),
//     );
//   }

//   bool tapTile(int row, int col) {
//     final tile = board[row][col];

//     if (tile.type != TileType.arrow || tile.isEscaped) {
//       return false;
//     }

//     if (_canEscape(row, col, tile.direction!)) {
//       tile.isEscaped = true;
//       movesCount++;
//       return true;
//     }

//     return false;
//   }

//   bool _canEscape(int startRow, int startCol, Direction dir) {
//     int r = startRow;
//     int c = startCol;

//     while (true) {
//       switch (dir) {
//         case Direction.up:
//           r--;
//           break;
//         case Direction.down:
//           r++;
//           break;
//         case Direction.left:
//           c--;
//           break;
//         case Direction.right:
//           c++;
//           break;
//       }

//       if (r < 0 || r >= rows || c < 0 || c >= cols) {
//         return true;
//       }

//       final nextTile = board[r][c];

//       if (!nextTile.isEscaped && nextTile.type != TileType.empty) {
//         return false;
//       }
//     }
//   }

//   bool isLevelComplete() {
//     for (var r = 0; r < rows; r++) {
//       for (var c = 0; c < cols; c++) {
//         final tile = board[r][c];
//         if (tile.type == TileType.arrow && !tile.isEscaped) {
//           return false;
//         }
//       }
//     }
//     return true;
//   }
// }

import 'level_data.dart';

enum Direction { up, down, left, right }

enum TileType { empty, arrow, prism, portal, wall }

/// Represents a specific coordinate on the grid board
class GridPoint {
  final int r;
  final int c;
  GridPoint(this.r, this.c);
}

/// Represents an individual cell tile on the grid
class GridTile {
  final int row;
  final int col;
  TileType type;
  Direction? direction;
  bool isEscaped;

  GridTile({
    required this.row,
    required this.col,
    this.type = TileType.empty,
    this.direction,
    this.isEscaped = false,
  });
}

/// Core Game Engine managing grid state, collisions, and ray-tracing logic
class GameEngine {
  int rows = 3;
  int cols = 3;
  late List<List<GridTile>> board;
  int movesCount = 0;
  int currentLevelIndex = 0;
  late LevelConfig currentConfig;

  GameEngine() {
    loadLevel(0);
  }

  void loadLevel(int levelIndex) {
    final levels = LevelRepository.getLevels();
    if (levelIndex >= levels.length) {
      currentLevelIndex = 0; // Loop back to level 1 when all are finished
    } else {
      currentLevelIndex = levelIndex;
    }

    currentConfig = levels[currentLevelIndex];
    rows = currentConfig.rows;
    cols = currentConfig.cols;
    movesCount = 0;

    _initBoard();

    for (var tileData in currentConfig.tiles) {
      board[tileData.row][tileData.col] = GridTile(
        row: tileData.row,
        col: tileData.col,
        type: tileData.type,
        direction: tileData.direction,
      );
    }
  }

  void nextLevel() {
    loadLevel(currentLevelIndex + 1);
  }

  void resetCurrentLevel() {
    loadLevel(currentLevelIndex);
  }

  void _initBoard() {
    board = List.generate(
      rows,
      (r) => List.generate(cols, (c) => GridTile(row: r, col: c)),
    );
  }

  /// Traces the laser trajectory.
  /// Returns a list of coordinates (path) if the arrow escapes, or null if it hits an obstacle.
  List<GridPoint>? attemptEscape(int startRow, int startCol, Direction dir) {
    List<GridPoint> path = [GridPoint(startRow, startCol)];
    int r = startRow;
    int c = startCol;
    Direction currentDir = dir;

    while (true) {
      switch (currentDir) {
        case Direction.up:
          r--;
          break;
        case Direction.down:
          r++;
          break;
        case Direction.left:
          c--;
          break;
        case Direction.right:
          c++;
          break;
      }

      // Success! The beam has safely exited the board boundaries.
      if (r < 0 || r >= rows || c < 0 || c >= cols) {
        path.add(GridPoint(r, c));
        return path;
      }

      final nextTile = board[r][c];
      path.add(GridPoint(r, c));

      // Collision detected: Wall or another un-escaped arrow blocks the path.
      if (nextTile.type == TileType.wall ||
          (nextTile.type == TileType.arrow && !nextTile.isEscaped)) {
        return null;
      }

      // Prism Mechanic: Bend the laser 90 degrees clockwise.
      if (nextTile.type == TileType.prism) {
        currentDir = _bendClockwise(currentDir);
      }

      // Portal Mechanic: Teleport the laser to the paired portal.
      if (nextTile.type == TileType.portal) {
        GridPoint destination = _findPairedPortal(r, c);
        r = destination.r;
        c = destination.c;
        path.add(GridPoint(r, c));
      }
    }
  }

  /// Handles user tapping a grid tile
  bool tapTile(int row, int col) {
    final tile = board[row][col];

    if (tile.type != TileType.arrow || tile.isEscaped) {
      return false;
    }

    final path = attemptEscape(row, col, tile.direction!);
    if (path != null) {
      tile.isEscaped = true;
      movesCount++;
      return true; // Arrow successfully escaped!
    }

    return false; // Collision occurred, arrow stays placed
  }

  Direction _bendClockwise(Direction dir) {
    if (dir == Direction.up) return Direction.right;
    if (dir == Direction.right) return Direction.down;
    if (dir == Direction.down) return Direction.left;
    return Direction.up;
  }

  GridPoint _findPairedPortal(int currentR, int currentC) {
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        if (board[i][j].type == TileType.portal &&
            (i != currentR || j != currentC)) {
          return GridPoint(i, j);
        }
      }
    }
    return GridPoint(currentR, currentC);
  }

  bool isLevelComplete() {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final tile = board[r][c];
        if (tile.type == TileType.arrow && !tile.isEscaped) {
          return false;
        }
      }
    }
    return true;
  }
}

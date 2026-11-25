import 'package:flutter/material.dart' hide GridTile;
import 'package:flutter/services.dart';
import 'package:orbit_escape/Logic/game_logic.dart';
import 'package:orbit_escape/paint/laser_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

// Added SingleTickerProviderStateMixin for the AnimationController
class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameEngine engine;
  late AnimationController _laserController;

  // State variables for the laser animation
  List<Offset> _currentLaserPath = [];
  int? _animatingRow;
  int? _animatingCol;

  // ---> ADD THEM RIGHT HERE <---
  int? _errorRow;
  int? _errorCol;

  @override
  void initState() {
    super.initState();
    engine = GameEngine();

    // Initialize the high-performance animation controller
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _handleTileTap(int r, int c, double gridWidth) {
    // Prevent tapping while an animation is already running
    if (_laserController.isAnimating) return;

    final tile = engine.board[r][c];
    if (tile.type != TileType.arrow || tile.isEscaped) return;

    // Call the ray-tracing engine to check the path
    final path = engine.attemptEscape(r, c, tile.direction!);

    if (path != null) {
      // 1. Success! Calculate pixel path for the UI
      HapticFeedback.lightImpact();

      // Calculate tile size.
      // We removed grid spacing and used padding instead to make math perfectly accurate.
      double tileSize = gridWidth / engine.cols;

      List<Offset> pixelPath = path.map((point) {
        return Offset(
          point.c * tileSize + (tileSize / 2),
          point.r * tileSize + (tileSize / 2),
        );
      }).toList();

      // 2. Set the state to prepare the CustomPainter
      setState(() {
        _currentLaserPath = pixelPath;
        _animatingRow = r;
        _animatingCol = c;
      });

      // 3. Fire the animation!
      _laserController.forward(from: 0.0).then((_) {
        // 4. Clean up after animation finishes
        setState(() {
          tile.isEscaped = true;
          engine.movesCount++;
          _currentLaserPath = [];
          _animatingRow = null;
          _animatingCol = null;

          if (engine.isLevelComplete()) {
            _showLevelCompleteDialog();
          }
        });
      });
    } else {
      // Collision detected - Play an error haptic and flash red
      HapticFeedback.heavyImpact();
      setState(() {
        _errorRow = r;
        _errorCol = c;
      });

      // Reset the error color back to normal after 300 milliseconds
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _errorRow == r && _errorCol == c) {
          setState(() {
            _errorRow = null;
            _errorCol = null;
          });
        }
      });
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "LEVEL ${engine.currentConfig.levelNumber} CLEARED!",
          style: TextStyle(
            color: engine.currentConfig.primaryGlowColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Great job! Preparing Level ${engine.currentConfig.levelNumber + 1}.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                engine.nextLevel();
              });
            },
            child: Text(
              "NEXT LEVEL",
              style: TextStyle(
                color: engine.currentConfig.primaryGlowColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = engine.currentConfig.primaryGlowColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildHeaderBar(themeColor),
            const Spacer(),
            _buildPuzzleGrid(themeColor),
            const Spacer(),
            _buildBottomControls(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard("LEVEL", "${engine.currentConfig.levelNumber}"),
          Text(
            engine.currentConfig.levelTitle,
            style: TextStyle(
              color: themeColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              shadows: [
                Shadow(color: themeColor.withOpacity(0.6), blurRadius: 10),
              ],
            ),
          ),
          _buildStatCard("MOVES", "${engine.movesCount}"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleGrid(Color themeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      // Use LayoutBuilder to get exact pixel dimensions for the CustomPainter
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AspectRatio(
            aspectRatio: engine.cols / engine.rows,
            child: Stack(
              clipBehavior: Clip.none, // Allow lasers to shoot off the board!
              children: [
                // Layer 1: The Interactive Tile Grid
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: engine.rows * engine.cols,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: engine.cols,
                    crossAxisSpacing: 0, // Set to 0 to keep math clean
                    mainAxisSpacing: 0,
                  ),
                  itemBuilder: (context, index) {
                    int r = index ~/ engine.cols;
                    int c = index % engine.cols;
                    GridTile tile = engine.board[r][c];

                    return GestureDetector(
                      onTap: () => _handleTileTap(r, c, constraints.maxWidth),
                      // Added padding here instead of grid spacing for perfect centering
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _buildTileWidget(
                          tile,
                          themeColor,
                          r == _animatingRow && c == _animatingCol,
                          r,
                          c,
                        ),
                      ),
                    );
                  },
                ),

                // Layer 2: The Neon Laser Animation Overlay
                if (_currentLaserPath.isNotEmpty)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: LaserPainter(
                          pixelPath: _currentLaserPath,
                          animation: _laserController,
                          laserColor: themeColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget _buildTileWidget(
  //   GridTile tile,
  //   Color themeColor,
  //   bool isCurrentlyAnimating,
  // ) {
  //   // Hide tile if it has escaped OR if it's currently shooting the laser
  //   if (tile.isEscaped || isCurrentlyAnimating) {
  //     return const SizedBox.shrink();
  //   }

  //   IconData iconData = Icons.north;
  //   if (tile.direction == Direction.down) iconData = Icons.south;
  //   if (tile.direction == Direction.right) iconData = Icons.east;
  //   if (tile.direction == Direction.left) iconData = Icons.west;

  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 250),
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.07),
  //       borderRadius: BorderRadius.circular(14),
  //       border: Border.all(
  //         color: tile.type == TileType.arrow
  //             ? themeColor
  //             : Colors.white.withOpacity(0.1),
  //         width: 1.5,
  //       ),
  //       boxShadow: tile.type == TileType.arrow
  //           ? [
  //               BoxShadow(
  //                 color: themeColor.withOpacity(0.4),
  //                 blurRadius: 12,
  //                 spreadRadius: 1,
  //               ),
  //             ]
  //           : [],
  //     ),
  //     child: Center(
  //       child: tile.type == TileType.arrow
  //           ? Icon(iconData, color: themeColor, size: 28)
  //           : const SizedBox.shrink(),
  //     ),
  //   );
  // }

  Widget _buildTileWidget(
    GridTile tile,
    Color themeColor,
    bool isCurrentlyAnimating,
    int r,
    int c,
  ) {
    // Hide tile if it has escaped OR if it's currently shooting the laser
    if (tile.isEscaped || isCurrentlyAnimating) {
      return const SizedBox.shrink();
    }

    // Check if this specific tile is currently in an error state
    bool isError = (_errorRow == r && _errorCol == c);
    Color currentColor = isError ? Colors.redAccent : themeColor;

    IconData iconData = Icons.north;
    if (tile.direction == Direction.down) iconData = Icons.south;
    if (tile.direction == Direction.right) iconData = Icons.east;
    if (tile.direction == Direction.left) iconData = Icons.west;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150), // Fast snap for error flash
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tile.type == TileType.arrow
              ? currentColor
              : Colors.white.withOpacity(0.1),
          width: isError ? 2.5 : 1.5, // Thicker border when blocked
        ),
        boxShadow: tile.type == TileType.arrow
            ? [
                BoxShadow(
                  color: currentColor.withOpacity(isError ? 0.6 : 0.4),
                  blurRadius: isError ? 20 : 12, // Bigger glow when blocked
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Center(
        child: tile.type == TileType.arrow
            ? Icon(iconData, color: currentColor, size: 28)
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.refresh, "RESET", () {
            setState(() {
              engine.resetCurrentLevel();
            });
          }),
          _buildActionButton(Icons.lightbulb_outline, "HINT", () {}),
          _buildActionButton(Icons.settings, "SETTINGS", () {}),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.white70),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white70),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.06),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

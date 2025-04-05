import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import 'token_widget.dart';

class LudoBoard extends StatelessWidget {
  LudoBoard({Key? key}) : super(key: key);

  final GameController gameController = Get.find<GameController>();

  // Board positions mapping (will be simplified for this example)
  // In a real implementation, this would be a more complex mapping of
  // coordinates for each position (0-57) for each color
  final Map<String, List<List<double>>> _positionsMap = {
    'red': [
      [0.2, 0.2], // Home position
      [0.3, 0.1], // First step
      // ... more positions
    ],
    'blue': [
      [0.8, 0.2], // Home position
      [0.7, 0.1], // First step
      // ... more positions
    ],
    'green': [
      [0.8, 0.8], // Home position
      [0.9, 0.7], // First step
      // ... more positions
    ],
    'yellow': [
      [0.2, 0.8], // Home position
      [0.1, 0.7], // First step
      // ... more positions
    ],
  };

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0, // Square board
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Obx(() {
          // Check if theme has a custom board image
          final theme = gameController.currentTheme.value;
          final boardPath = theme.boardPath;

          return Stack(
            children: [
              // Board background
              boardPath != null
                  ? Image.asset(
                      boardPath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : _buildDefaultBoard(),

              // Tokens for each player
              ..._buildTokens(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDefaultBoard() {
    return CustomPaint(
      painter: LudoBoardPainter(),
      size: Size.infinite,
    );
  }

  List<Widget> _buildTokens() {
    final List<Widget> tokens = [];

    gameController.tokenPositions.forEach((color, positions) {
      for (int i = 0; i < positions.length; i++) {
        final position = positions[i];

        // Skip if position map doesn't have this color or position
        if (!_positionsMap.containsKey(color) ||
            _positionsMap[color]!.length <= position) {
          continue;
        }

        // Get relative position (0-1 range)
        final pos = _positionsMap[color]![position];

        // Add token widget
        tokens.add(
          Positioned(
            left: pos[0] * MediaQuery.of(Get.context!).size.width * 0.7,
            top: pos[1] * MediaQuery.of(Get.context!).size.width * 0.7,
            child: TokenWidget(
              color: color,
              tokenIndex: i,
              onTap: () {
                if (gameController.canMoveToken(i)) {
                  gameController.moveToken(i);
                }
              },
              isSelectable: gameController.canMoveToken(i),
            ),
          ),
        );
      }
    });

    return tokens;
  }
}

class LudoBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw board sections

    // Red section
    paint.color = Colors.red.withOpacity(0.2);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width / 2, size.height / 2),
      paint,
    );

    // Blue section
    paint.color = Colors.blue.withOpacity(0.2);
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height / 2),
      paint,
    );

    // Green section
    paint.color = Colors.green.withOpacity(0.2);
    canvas.drawRect(
      Rect.fromLTWH(
          size.width / 2, size.height / 2, size.width / 2, size.height / 2),
      paint,
    );

    // Yellow section
    paint.color = Colors.yellow.withOpacity(0.2);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2, size.width / 2, size.height / 2),
      paint,
    );

    // Draw central home
    paint.color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.3,
        size.width * 0.4,
        size.height * 0.4,
      ),
      paint,
    );

    // Draw paths (simplified)
    paint.color = Colors.white;
    paint.strokeWidth = 2;

    // Horizontal main path
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.2),
      paint,
    );

    // Vertical main path
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.4, 0, size.width * 0.2, size.height),
      paint,
    );

    // Draw grid lines
    paint.color = Colors.black;
    paint.strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i <= 15; i++) {
      canvas.drawLine(
        Offset(0, size.height * i / 15),
        Offset(size.width, size.height * i / 15),
        paint,
      );
    }

    // Vertical grid lines
    for (int i = 0; i <= 15; i++) {
      canvas.drawLine(
        Offset(size.width * i / 15, 0),
        Offset(size.width * i / 15, size.height),
        paint,
      );
    }

    // Draw home bases for each color
    final homePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Red home base
    homePaint.color = Colors.red;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2),
        size.width * 0.1, homePaint);

    // Blue home base
    homePaint.color = Colors.blue;
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2),
        size.width * 0.1, homePaint);

    // Green home base
    homePaint.color = Colors.green;
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.8),
        size.width * 0.1, homePaint);

    // Yellow home base
    homePaint.color = Colors.yellow;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8),
        size.width * 0.1, homePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

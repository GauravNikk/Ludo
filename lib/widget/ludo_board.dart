import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import 'token_widget.dart';

class LudoBoard extends StatelessWidget {
  LudoBoard({super.key});

  // Define color-specific starting positions on the global path
  final Map<String, int> startPositions = {
    'red': 0,
    'green': 13,
    'yellow': 26,
    'blue': 39
  };

  // Define final positions for each color's path to home
  final Map<String, List<int>> homePathIndexes = {
    'red': [51, 52, 53, 54, 55, 56],
    'green': [12, 64, 65, 66, 67, 68],
    'yellow': [25, 70, 71, 72, 73, 74],
    'blue': [38, 58, 59, 60, 61, 62]
  };

  // Complete global path for all 52 main board positions
  final List<Offset> globalPath = [
    // Red start section (0-12)
    Offset(1, 6), Offset(2, 6), Offset(3, 6), Offset(4, 6),
    Offset(5, 6), Offset(6, 5), Offset(6, 4), Offset(6, 3),
    Offset(6, 2), Offset(6, 1), Offset(6, 0), Offset(7, 0),
    Offset(8, 0),

    // Green start section (13-25)
    Offset(8, 1), Offset(8, 2), Offset(8, 3), Offset(8, 4),
    Offset(8, 5), Offset(9, 6), Offset(10, 6), Offset(11, 6),
    Offset(12, 6), Offset(13, 6), Offset(14, 6), Offset(14, 7),
    Offset(14, 8),

    // Yellow start section (26-38)
    Offset(13, 8), Offset(12, 8), Offset(11, 8), Offset(10, 8),
    Offset(9, 8), Offset(8, 9), Offset(8, 10), Offset(8, 11),
    Offset(8, 12), Offset(8, 13), Offset(8, 14), Offset(7, 14),
    Offset(6, 14),

    // Blue start section (39-51)
    Offset(6, 13), Offset(6, 12), Offset(6, 11), Offset(6, 10),
    Offset(6, 9), Offset(5, 8), Offset(4, 8), Offset(3, 8),
    Offset(2, 8), Offset(1, 8), Offset(0, 8), Offset(0, 7),
    Offset(0, 6)
  ];

  // Home paths for each color
  final Map<String, List<Offset>> homePaths = {
    'red': [
      Offset(1, 7),
      Offset(2, 7),
      Offset(3, 7),
      Offset(4, 7),
      Offset(5, 7),
      Offset(6, 7)
    ],
    'green': [
      Offset(7, 1),
      Offset(7, 2),
      Offset(7, 3),
      Offset(7, 4),
      Offset(7, 5),
      Offset(7, 6)
    ],
    'yellow': [
      Offset(13, 7),
      Offset(12, 7),
      Offset(11, 7),
      Offset(10, 7),
      Offset(9, 7),
      Offset(8, 7)
    ],
    'blue': [
      Offset(7, 13),
      Offset(7, 12),
      Offset(7, 11),
      Offset(7, 10),
      Offset(7, 9),
      Offset(7, 8)
    ]
  };

  // Home base positions for each color's tokens
  final Map<String, List<Offset>> homeBasePositions = {
    'red': [Offset(2, 2), Offset(4, 2), Offset(2, 4), Offset(4, 4)],
    'green': [Offset(10, 2), Offset(12, 2), Offset(10, 4), Offset(12, 4)],
    'yellow': [Offset(10, 10), Offset(12, 10), Offset(10, 12), Offset(12, 12)],
    'blue': [Offset(2, 10), Offset(4, 10), Offset(2, 12), Offset(4, 12)]
  };

  // Safe positions marked with stars
  final List<int> safePositions = [0, 8, 13, 21, 26, 34, 39, 47];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileSize = constraints.maxWidth / 15;
          return Stack(
            children: [
              // The board background and tiles
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: LudoBoardPainter(
                  globalPath: globalPath,
                  safePositions: safePositions,
                  homePaths: homePaths,
                  homeBasePositions: homeBasePositions,
                ),
              ),
               _buildTokens(tileSize),
            ],
          );
        },
      ),
    );
  }

 Widget _buildTokens(double tileSize) {
    final GameController gameController = Get.find<GameController>();

    return Obx(() {
      List<Widget> tokens = [];

      // Home base tokens
      homeBasePositions.forEach((color, positions) {
        final tokenPositions =
            gameController.tokenPositions[color] ?? List.filled(4, -1);
        for (int i = 0; i < positions.length; i++) {
          if (tokenPositions[i] == -1) {
            tokens.add(
              Positioned(
                left: positions[i].dx * tileSize,
                top: positions[i].dy * tileSize,
                child: TokenWidget(
                  color: color,
                  tokenIndex: i,
                  isSelectable: gameController.canMoveToken(i),
                  onTap: () => gameController.moveToken(i),
                ),
              ),
            );
          }
        }
      });

      // Tokens on main path or home path
      gameController.tokenPositions.forEach((color, tokenPositions) {
        for (int i = 0; i < tokenPositions.length; i++) {
          final position = tokenPositions[i];
          if (position == -1) continue;

          Offset tokenOffset;
          if (position < 52) {
            int adjustedPosition = (position + startPositions[color]!) % 52;
            tokenOffset = globalPath[adjustedPosition];
          } else if (position >= 52 && position < 58) {
            int homePathIndex = position - 52;
            tokenOffset = homePaths[color]![homePathIndex];
          } else {
            tokenOffset = const Offset(7, 7); // reached final
          }

          tokens.add(
            Positioned(
              left: tokenOffset.dx * tileSize,
              top: tokenOffset.dy * tileSize,
              child: TokenWidget(
                color: color,
                tokenIndex: i,
                isSelectable: gameController.canMoveToken(i),
                onTap: () => gameController.moveToken(i),
              ),
            ),
          );
        }
      });

      return Stack(children: tokens);
    });
  }


}

class LudoBoardPainter extends CustomPainter {
  final List<Offset> globalPath;
  final List<int> safePositions;
  final Map<String, List<Offset>> homePaths;
  final Map<String, List<Offset>> homeBasePositions;

  LudoBoardPainter({
    required this.globalPath,
    required this.safePositions,
    required this.homePaths,
    required this.homeBasePositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tileSize = size.width / 15;
    final paint = Paint();

    // Draw the board background
    _drawBoardBackground(canvas, size, tileSize);

    // Draw home bases
    _drawHomeBases(canvas, size, tileSize);

    // Draw main path
    _drawMainPath(canvas, tileSize);

    // Draw home paths
    _drawHomePaths(canvas, tileSize);

    // Draw center home
    _drawCenterHome(canvas, tileSize);
  }

  void _drawBoardBackground(Canvas canvas, Size size, double tileSize) {
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 15; i++) {
      // Vertical lines
      canvas.drawLine(Offset(i * tileSize, 0),
          Offset(i * tileSize, size.height), gridPaint);

      // Horizontal lines
      canvas.drawLine(
          Offset(0, i * tileSize), Offset(size.width, i * tileSize), gridPaint);
    }
  }

  void _drawHomeBases(Canvas canvas, Size size, double tileSize) {
    final Map<String, Color> colorMap = {
      'red': Colors.red,
      'green': Colors.green,
      'blue': Colors.blue,
      'yellow': Colors.yellow,
    };

    // Draw home base areas
    // Red (top-left)
    _drawColoredSquare(
        canvas, tileSize, 0, 0, 6, 6, colorMap['red']!.withOpacity(0.2));

    // Green (top-right)
    _drawColoredSquare(
        canvas, tileSize, 9, 0, 6, 6, colorMap['green']!.withOpacity(0.2));

    // Yellow (bottom-right)
    _drawColoredSquare(
        canvas, tileSize, 9, 9, 6, 6, colorMap['yellow']!.withOpacity(0.2));

    // Blue (bottom-left)
    _drawColoredSquare(
        canvas, tileSize, 0, 9, 6, 6, colorMap['blue']!.withOpacity(0.2));

    // Draw the inner home bases (where tokens start)
    colorMap.forEach((color, paintColor) {
      final positions = homeBasePositions[color]!;
      for (final pos in positions) {
        final circleRadius = tileSize * 0.4;
        final circlePaint = Paint()
          ..color = paintColor.withOpacity(0.6)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
            Offset((pos.dx + 0.5) * tileSize, (pos.dy + 0.5) * tileSize),
            circleRadius,
            circlePaint);

        // Add border
        canvas.drawCircle(
            Offset((pos.dx + 0.5) * tileSize, (pos.dy + 0.5) * tileSize),
            circleRadius,
            Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
      }
    });
  }

  void _drawColoredSquare(Canvas canvas, double tileSize, int startX,
      int startY, int width, int height, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(
        Rect.fromLTWH(startX * tileSize, startY * tileSize, width * tileSize,
            height * tileSize),
        paint);

    // Add border
    canvas.drawRect(
        Rect.fromLTWH(startX * tileSize, startY * tileSize, width * tileSize,
            height * tileSize),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  void _drawMainPath(Canvas canvas, double tileSize) {
    for (int i = 0; i < globalPath.length; i++) {
      final pos = globalPath[i];
      final Paint tilePaint = Paint();

      // Determine if it's a safe position
      if (safePositions.contains(i)) {
        tilePaint.color = Colors.orange.withOpacity(0.7);
      } else {
        tilePaint.color = Colors.white;
      }

      // Draw the path tile
      canvas.drawRect(
          Rect.fromLTWH(
              pos.dx * tileSize, pos.dy * tileSize, tileSize, tileSize),
          tilePaint);

      // Add tile border
      canvas.drawRect(
          Rect.fromLTWH(
              pos.dx * tileSize, pos.dy * tileSize, tileSize, tileSize),
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);

      // Add star for safe positions
      if (safePositions.contains(i)) {
        _drawStar(canvas, pos.dx * tileSize + tileSize / 2,
            pos.dy * tileSize + tileSize / 2, tileSize * 0.3);
      }
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double radius) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    final int nPoints = 5;
    final double angle = (2 * 3.1415926) / nPoints;

    for (int i = 0; i < nPoints * 2; i++) {
      double r = (i % 2 == 0) ? radius : radius * 0.4;
      double currAngle = i * angle / 2;

      double x = cx + r * cos(currAngle - 3.1415926 / 2);
      double y = cy + r * sin(currAngle - 3.1415926 / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.fill);
  }

  void _drawHomePaths(Canvas canvas, double tileSize) {
    final Map<String, Color> colorMap = {
      'red': Colors.red,
      'green': Colors.green,
      'blue': Colors.blue,
      'yellow': Colors.yellow,
    };

    colorMap.forEach((color, paintColor) {
      final path = homePaths[color]!;

      for (final pos in path) {
        // Draw home path tile
        canvas.drawRect(
            Rect.fromLTWH(
                pos.dx * tileSize, pos.dy * tileSize, tileSize, tileSize),
            Paint()..color = paintColor.withOpacity(0.3));

        // Add tile border
        canvas.drawRect(
            Rect.fromLTWH(
                pos.dx * tileSize, pos.dy * tileSize, tileSize, tileSize),
            Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
      }
    });
  }

  void _drawCenterHome(Canvas canvas, double tileSize) {
    // Draw center home area
    final centerPaint = Paint()..color = Colors.grey.withOpacity(0.2);

    canvas.drawRect(
        Rect.fromLTWH(6 * tileSize, 6 * tileSize, 3 * tileSize, 3 * tileSize),
        centerPaint);

    // Draw border
    canvas.drawRect(
        Rect.fromLTWH(6 * tileSize, 6 * tileSize, 3 * tileSize, 3 * tileSize),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Draw finish area
    final Map<String, Paint> finishPaints = {
      'red': Paint()..color = Colors.red,
      'green': Paint()..color = Colors.green,
      'yellow': Paint()..color = Colors.yellow,
      'blue': Paint()..color = Colors.blue
    };

    // Draw the triangular finish areas
    _drawTriangle(
        canvas, tileSize, 7.5, 6, 6, 7.5, 9, 7.5, finishPaints['red']!);
    _drawTriangle(
        canvas, tileSize, 9, 7.5, 7.5, 6, 7.5, 9, finishPaints['green']!);
    _drawTriangle(
        canvas, tileSize, 7.5, 9, 9, 7.5, 6, 7.5, finishPaints['yellow']!);
    _drawTriangle(
        canvas, tileSize, 6, 7.5, 7.5, 9, 7.5, 6, finishPaints['blue']!);
  }

  void _drawTriangle(Canvas canvas, double tileSize, double x1, double y1,
      double x2, double y2, double x3, double y3, Paint paint) {
    final path = Path();
    path.moveTo(x1 * tileSize, y1 * tileSize);
    path.lineTo(x2 * tileSize, y2 * tileSize);
    path.lineTo(x3 * tileSize, y3 * tileSize);
    path.close();

    canvas.drawPath(path, paint);

    // Add border
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class TokenWidget extends StatelessWidget {
  final String color;
  final int tokenIndex;
  final VoidCallback onTap;
  final bool isSelectable;

  const TokenWidget({
    Key? key,
    required this.color,
    required this.tokenIndex,
    required this.onTap,
    required this.isSelectable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();
    final theme = gameController.currentTheme.value;

    // Check if theme has custom token for this color
    final tokenPath =
        theme.tokenPaths != null ? theme.tokenPaths![color] : null;

    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelectable
              ? _getTokenColor().withOpacity(0.7)
              : _getTokenColor(),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          boxShadow: isSelectable
              ? [
                  BoxShadow(
                    color: _getTokenColor().withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 3,
                  )
                ]
              : null,
        ),
        child: tokenPath != null
            ? ClipOval(
                child: Image.asset(
                  tokenPath,
                  fit: BoxFit.cover,
                ),
              )
            : Center(
                child: Text(
                  (tokenIndex + 1).toString(),
                  style: TextStyle(
                    color: _getTokenColor() == Colors.yellow
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  Color _getTokenColor() {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}

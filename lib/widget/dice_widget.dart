import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class DiceWidget extends StatelessWidget {
  final RxInt diceValue;
  final RxBool isRolling;
  final VoidCallback onRoll;
  final bool canRoll;

  const DiceWidget({
    Key? key,
    required this.diceValue,
    required this.isRolling,
    required this.onRoll,
    required this.canRoll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();
    final theme = gameController.currentTheme.value;

    return GestureDetector(
      onTap: canRoll ? onRoll : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          boxShadow: canRoll
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Obx(() {
          // Check if theme has custom dice face
          final diceFaces = theme.diceFacePaths;
          final value = diceValue.value;

          if (diceFaces != null && value > 0 && value <= diceFaces.length) {
            return Image.asset(
              diceFaces[value - 1],
              fit: BoxFit.cover,
            );
          }

          return Center(
            child: isRolling.value
                ? const CircularProgressIndicator()
                : Text(
                    diceValue.value.toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          );
        }),
      ),
    );
  }
}

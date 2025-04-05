import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../widget/dice_widget.dart';
import '../widget/ludo_board.dart';
import '../widget/player_info_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Ludo Game'),
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      // ),
      body: Obx(() {
        final playerList = gameController.players ?? [];

        return Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: playerList.map((player) {
                    return Expanded(
                      child: PlayerInfoWidget(
                        player: player,
                        isCurrentTurn:
                            player.uid == gameController.currentTurn.value,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Middle section - Ludo board
             Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: LudoBoard(),
              ),
            ),

            // Bottom section - Dice and controls
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Turn indicator
                    Obx(() {
                      final isMyTurn = gameController.isMyTurn();
                      return Text(
                        isMyTurn ? 'Your Turn!' : 'Waiting for opponent...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isMyTurn ? Colors.green : Colors.grey,
                        ),
                      );
                    }),

                    // Timer
                    Obx(() => Text(
                          'Time left: ${gameController.turnTimeLeft.value}s',
                          style: const TextStyle(fontSize: 11, color: Colors.red),
                        )),

                    const SizedBox(height: 10),

                    // Dice
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DiceWidget(
                          diceValue: gameController.diceValue,
                          isRolling: gameController.isDiceRolling,
                          onRoll: () => gameController.rollDice(),
                          canRoll: gameController.isMyTurn() &&
                              !gameController.isWaitingForMove.value,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

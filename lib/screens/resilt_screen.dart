import 'package:aag_user/screens/waiting_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Game Over!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Winner Section
              Obx(() {
                final winnerIndex = gameController.winner.value;
                final winner = gameController.player![winnerIndex];

                if (winner != null) {
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: _getColorFromString(winner.color),
                        backgroundImage: winner.avatar.isNotEmpty
                            ? NetworkImage(winner.avatar)
                            : null,
                        child: winner.avatar.isEmpty
                            ? Text(winner.name[0].toUpperCase(),
                                style: const TextStyle(fontSize: 40))
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Winner: ${winner.name}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Score: ${winner.score} points',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  );
                }
                return const Text('No winner determined');
              }),

              const SizedBox(height: 40),
              const Text(
                'Final Scores:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // All Player Scores List
              Obx(() {
                final player! = gameController.player!.values.toList()
                  ..sort((a, b) => b.score.compareTo(a.score));

                return Column(
                  children: player!.map((player) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorFromString(player.color),
                          child: Text(player.name[0].toUpperCase()),
                        ),
                        title: Text(player.name),
                        subtitle: Text('Moves: ${100 - player.movesLeft}/100'),
                        trailing: Text(
                          '${player.score} pts',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 40),

              // Play Again Button
              ElevatedButton(
                onPressed: () {
                  Get.delete<GameController>();
                  Get.put(GameController());
                  Get.offAll(() => const WaitingScreen());
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Play Again', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromString(String color) {
    switch (color.toLowerCase()) {
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

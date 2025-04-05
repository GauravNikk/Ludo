import 'package:aag_user/controllers/game_controller.dart';
import 'package:aag_user/screens/game_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({Key? key}) : super(key: key);

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  final GameController gameController = Get.find<GameController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showRoomDialog());
  }

  Future<void> _showRoomDialog() async {
    final TextEditingController codeController = TextEditingController();
    final deviceInfo = DeviceInfoPlugin();
    String deviceName = 'Player';

    if (GetPlatform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      deviceName = info.model ?? 'Android';
    } else if (GetPlatform.isIOS) {
      final info = await deviceInfo.iosInfo;
      deviceName = info.name ?? 'iOS';
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Enter 4-digit Room Code'),
          content: TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
              hintText: 'Eg. 1234',
              counterText: "",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final code = codeController.text.trim();
                if (code.length == 4) {
                  final roomSnapshot =
                      await FirebaseDatabase.instance.ref('rooms/$code').get();

                  if (!roomSnapshot.exists) {
                    // Room doesn't exist, create it
                    await gameController.createRoom(
                      deviceName,
                      'https://avatar.iran.liara.run/public',
                      roomId: code,
                    );
                    Get.back();
                  } else {
                    final player! = roomSnapshot.child('player!').value as Map?;
                    if (player! != null && player!.length < 4) {
                      // Room exists and has space
                      _showAvailableDialog(code, deviceName);
                    } else {
                      // Room full
                      Get.snackbar(
                          "Room Full", "This room already has 4 player!.");
                    }
                  }
                }
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showAvailableDialog(String code, String deviceName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Room Found"),
        content: Text("Room $code is available. Join now?"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await gameController.joinRoom(
                code,
                deviceName,
                'https://avatar.iran.liara.run/public',
              );
              Get.back(); // Close dialog
            },
            child: const Text("Join Now"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ludo Game - Waiting Room'),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Obx(() {
                if (gameController.roomId!.value != null) {
                  return _buildRoomInfo(gameController, isWide);
                } else {
                  return const CircularProgressIndicator();
                }
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomInfo(GameController gameController, bool isWide) {
    return isWide
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _roomDetails(gameController),
              _playerList(gameController),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _roomDetails(gameController),
              const SizedBox(height: 30),
              _playerList(gameController),
            ],
          );
  }

  Widget _roomDetails(GameController gameController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Waiting for player! to join...',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                'Room ID: ${gameController.roomId}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text('Share this code with friends to join'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Obx(() {
          final timeLeft = gameController.turnTimeLeft.value;
          if (gameController.player!.length == 1) {
            return Column(
              children: [
                Text(
                  'Game will start in $timeLeft seconds',
                  style: const TextStyle(fontSize: 16),
                ),
                const Text(
                  'If no one joins, you will automatically win!',
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            );
          } else if (gameController.player!.length > 1) {
            return ElevatedButton(
              onPressed: () {
                gameController.startGame();
                Get.off(() => const GameScreen());
              },
              child: const Text('Start Game'),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _playerList(GameController gameController) {
    return Column(
      children: [
        const Text(
          'Players in Room:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Obx(() => Column(
              children: gameController.player!.values.map((player) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorFromString(player.color),
                    child: Text(player.name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(player.name),
                  trailing: Icon(
                    Icons.circle,
                    color: player.isOnline! ? Colors.green : Colors.red,
                    size: 12,
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Color _getColorFromString(String color) {
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

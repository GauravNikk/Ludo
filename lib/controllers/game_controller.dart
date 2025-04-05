import 'dart:async';
import 'dart:math';
import 'package:aag_user/constta/colors_data.dart';
import 'package:aag_user/model/player_model.dart';
import 'package:aag_user/model/score_model.dart';
import 'package:aag_user/model/theme_model.dart';
import 'package:aag_user/screens/game_screen.dart';
import 'package:aag_user/screens/resilt_screen.dart';
import 'package:aag_user/service/api_service.dart';
import 'package:aag_user/service/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import '../service/theme_service.dart';

class GameController extends GetxController {
  final FirebaseService _firebaseService = Get.put(FirebaseService());
  final ApiService _apiService = Get.put(ApiService());
  final ThemeService _themeService = Get.put(ThemeService());

  final RxString? roomId = ''.obs;
  RxString currentPlayerColor = 'red'.obs; // or whatever your default color is

   Rx<Player> currentPlayer = Player().obs;
  final RxList<Player> players = <Player>[].obs;
  final RxInt currentTurn = 0.obs;
  final RxInt diceValue = 0.obs;
  final Rx<DateTime> turnStartedAt = DateTime.now().obs;
  final RxMap<String, List<int>> tokenPositions = <String, List<int>>{}.obs;
  final RxString winner = ''.obs;
  final RxBool isGameStarted = false.obs;
  final RxBool isDiceRolling = false.obs;
  final RxBool canRollDice = false.obs;
  final RxBool isWaitingForMove = false.obs;
  final RxInt turnTimeLeft = 15.obs;
  final Rx<ThemeModel> currentTheme = ThemeModel.defaultTheme().obs;

  Timer? _turnTimer;
  Timer? _waitingTimer;
  final _random = Random();

  @override
  void onInit() {
    super.onInit();
    setupDisconnectHandler();
  }

  @override
  void onClose() {
    _turnTimer?.cancel();
    _waitingTimer?.cancel();
    _firebaseService.disconnect();
    super.onClose();
  }

  void setupDisconnectHandler() {}

  Future<void> createRoom(BuildContext context, String name, String avatar, {String? roomId}) async {
    final db = FirebaseDatabase.instance.ref();
    final newRoomId = roomId;
    final roomRef = db.child('rooms').child(newRoomId!);
    final snapshot = await roomRef.get();

    if (snapshot.exists) {
      final playerCount = (snapshot.child('player').value as Map?)?.length ?? 0;

      if (playerCount < 4) {
        Get.dialog(AlertDialog(
          title: const Text("Room Available"),
          content: Text(
              "Room $newRoomId already exists with $playerCount player!. Do you want to join?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
               joinRoom(newRoomId, name, avatar);
              },
              child: const Text("Join Now"),
            ),
          ],
        ));
      } else {
        Get.snackbar("Room Full", "The room already has 4 player!.");
      }
    } else {
      int uid = DateTime.now()
          .millisecondsSinceEpoch
          .toString()
          .split('')
          .map(int.parse)
          .reduce((a, b) => a + b);
      final playerData = {
        "uid": uid,
        "name": name,
        "avatar": avatar,
        "color": ColorsData().getAvailableColor(),
        "score": 0,
        "movesLeft": 0,
        "missCount": 0,
        "isOnline": true,
      };

      await roomRef.set({
        "id": newRoomId,
        "turn": uid,
        "turnTimeLeft": 15,
        "player": {uid: playerData},
      });

      roomId = newRoomId;
      // players[uid] = Player.fromJson(playerData);
      players.add(Player.fromJson(playerData));

      Get.dialog(AlertDialog(
        title: const Text("Room Created"),
        content: Text("Room $newRoomId has been created."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              listenToRoom();
            },
            child: const Text("Join Now"),
          ),
        ],
      ));
    }
  }




 void listenToRoom() {
    final db = FirebaseDatabase.instance.ref();

    final roomRef = db.child('rooms').child(roomId!.value);

    roomRef.onValue.listen((event) {
      final data = event.snapshot.value as Map;
     print("Room Data: $data");
      print("Players fetched: ${players.length}");
      // Players
      final playerData = data['player'] as Map?;
      if (playerData != null) {
        players.clear();
        playerData.forEach((key, value) {
          final playerJson = Map<String, dynamic>.from(value);
          players.add(Player.fromJson(playerJson));
        });
      }

      // Winner
      if (data['winner'] != null && data['winner'].toString().isNotEmpty) {
        winner.value = data['winner'].toString();
        _goToResultScreen();
      }

      // Turn timer
      if (data['turnTimeLeft'] != null) {
        turnTimeLeft.value = data['turnTimeLeft'];
      }
       if (data == null) return;

      // Turn
      if (data['turn'] != null) {
        currentTurn.value = data['turn'];
      }

    });
  }

  Future<bool> joinRoom(
      String roomIdToJoin, String nickname, String avatar) async {
    final int uid = DateTime.now()
        .millisecondsSinceEpoch
        .toString()
        .split('')
        .map(int.parse)
        .reduce((a, b) => a + b);
    final String color = _getAvailableColor();
    final Player player =
        Player(uid: uid, name: nickname, avatar: avatar, color: color);
    currentPlayer.value = player;
    final success = await _firebaseService.joinRoom(roomIdToJoin, player);

print("success: $success");

    if (success) {
      _listenToRoomChanges();
      _loadTheme('default');
      return true;
    }
    return false;
  }

  void _listenToRoomChanges() {
    print("_listenToRoomChanges called");

    _firebaseService.listenToRoom().listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        print("_listenToRoomChanges called");
        print("Room Data: $data");
        print("Players fetched: ${players.length}");
        print("Current Player: ${currentPlayer.value}");
        print("Current Turn: ${currentTurn.value}");
        print("Dice Value: ${diceValue.value}");
        print("Turn Started At: ${turnStartedAt.value}");
        print("Token Positions: ${tokenPositions}");
        print("Winner: ${winner.value}");
        print("Is Game Started: ${isGameStarted.value}");
        print("Is Dice Rolling: ${isDiceRolling.value}");
        print("Can Roll Dice: ${canRollDice.value}");
        print("Is Waiting For Move: ${isWaitingForMove.value}");
        print("Turn Time Left: ${turnTimeLeft.value}");
        print("Current Theme: ${currentTheme.value}");
        print("Room ID: ${roomId?.value}");

        if (data['player'] != null) {
          final playersData = data['player'] as Map<dynamic, dynamic>;
          players.clear();

          // playersData.forEach((key, value) {
          //   final playerMap = Map<String, dynamic>.from(value);
          //   final player = Player.fromJson(playerMap);
          //   players.add(player); 
          // });

         playersData.forEach((key, value) {
            final playerMap = Map<String, dynamic>.from(value);
            final player = Player.fromJson(playerMap);
            print("Parsed Player: ${player.name} (uid: ${player.uid})");
            players.add(player);
          });

        }

        if (data['gameState'] != null) {
          final gameState = data['gameState'] as Map<dynamic, dynamic>;

          if (gameState['currentTurn'] != null) {
            currentTurn.value = gameState['currentTurn'];
          }

          if (gameState['diceValue'] != null) {
            diceValue.value = gameState['diceValue'] as int;
          }

          if (gameState['turnStartedAt'] != null) {
            turnStartedAt.value = DateTime.fromMillisecondsSinceEpoch(
                gameState['turnStartedAt'] as int);
            _resetTurnTimer();
          }

          if (gameState['tokenPositions'] != null) {
            final positions =
                gameState['tokenPositions'] as Map<dynamic, dynamic>;
            tokenPositions.clear();

            positions.forEach((key, value) {
              final colorPositions =
                  (value as List<dynamic>).map((e) => e as int).toList();
              tokenPositions[key.toString()] = colorPositions;
            });
          }
        }

        if (data['winner'] != null) {
          winner.value = data['winner'].toString();
          _goToResultScreen();
        }

        _checkGameState();
      }
    });
  }

  void _startWaitingTimer() {
    _waitingTimer?.cancel();
    _waitingTimer = Timer(const Duration(seconds: 15), () {
      if (players.length == 1 && winner.value.isEmpty) {
        _declareWinner(players.first.uid!);
      } else if (players.length > 1 && !isGameStarted.value) {
        startGame();
      }
    });
  }

  void startGame() {
    if (isGameStarted.value) return;

    isGameStarted.value = true;
    final firstPlayerId = players.first.uid!;
    _firebaseService.updateCurrentTurn(firstPlayerId);
    Get.off(() => const GameScreen());
  }

  void _resetTurnTimer() {
    _turnTimer?.cancel();
    turnTimeLeft.value = 15;

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (turnTimeLeft.value > 0) {
        turnTimeLeft.value--;
      } else {
        if (currentTurn.value == currentPlayer.value?.uid) {
          _handleMissedTurn();
        }
        timer.cancel();
      }
    });
  }

  void _handleMissedTurn() {
    if (currentPlayer.value == null) return;

    final p = players.firstWhere(
      (p) => p.uid == currentPlayer.value!.uid,
      orElse: () => Player(),
    );

    p.missCount = (p.missCount ?? 0) + 1;
    _firebaseService.updatePlayer(p);

    if (p.missCount! >= 3) {
      _eliminatePlayer(p.uid!);
    } else {
      _passTurnToNextPlayer();
    }
  }

  void _eliminatePlayer(int playerId) {
    if (players!.length <= 2) {
      _declareLastPlayerWinner();
    } else {
      _passTurnToNextPlayer();
    }
  }

  void _passTurnToNextPlayer() {
    if (players.isEmpty) return;

    final playerIds = players.map((p) => p.uid!).toList();
    final currentIndex = playerIds.indexOf(currentTurn.value);
    final nextIndex = (currentIndex + 1) % playerIds.length;
    final nextPlayerId = playerIds[nextIndex];

    _firebaseService.updateCurrentTurn(nextPlayerId);
  }

  Future<void> rollDice() async {
    if (!canRollDice.value || isDiceRolling.value) return;

    isDiceRolling.value = true;

    for (int i = 0; i < 10; i++) {
      diceValue.value = _random.nextInt(6) + 1;
      await Future.delayed(const Duration(milliseconds: 50));
    }

    final finalValue = _random.nextInt(6) + 1;
    isDiceRolling.value = false;

    await _firebaseService.rollDice(finalValue);
    await _checkIfPlayerCanMove(finalValue);
  }

  Future<void> _checkIfPlayerCanMove(int diceValue) async {
    if (currentPlayer.value == null) return;

    final color = currentPlayer.value!.color;
    final positions = tokenPositions[color] ?? [0, 0, 0, 0];
    bool canMove = false;

    for (int i = 0; i < positions.length; i++) {
      if (_canMoveToken(i, diceValue)) {
        canMove = true;
        break;
      }
    }

    if (!canMove) {
      await Future.delayed(const Duration(seconds: 1));
      _passTurnToNextPlayer();
    } else {
      isWaitingForMove.value = true;
    }
  }

  bool _canMoveToken(int tokenIndex, int diceValue) {
    if (currentPlayer.value == null) return false;

    final color = currentPlayer.value!.color;
    final positions = tokenPositions[color] ?? [0, 0, 0, 0];
    final currentPosition = positions[tokenIndex];

    if (currentPosition == 0 && diceValue != 6) {
      return false;
    }

    if (currentPosition + diceValue > 57) {
      return false;
    }

    return true;
  }

  Future<void> _checkForCaptures(String color, int position) async {
    if (_isSafePosition(position)) return;

    for (final otherColor in tokenPositions.keys) {
      if (otherColor == color) continue;

      final otherPositions = List<int>.from(tokenPositions[otherColor]!);

      for (int i = 0; i < otherPositions.length; i++) {
        if (otherPositions[i] == position && otherPositions[i] != 0) {
          otherPositions[i] = 0;
          tokenPositions[otherColor] = otherPositions;
          await _firebaseService.updateTokenPositions(
              otherColor, otherPositions);
          await _updateScore(color, 2);
        }
      }
    }
  }

  bool _isSafePosition(int position) {
    return [8, 13, 21, 26, 34, 39, 47].contains(position);
  }

  Future<void> moveToken(int tokenIndex) async {
    if (!isWaitingForMove.value || currentPlayer.value == null) return;

    final color = currentPlayer.value!.color;
    final positions = List<int>.from(tokenPositions[color] ?? [0, 0, 0, 0]);
    final currentPosition = positions[tokenIndex];
    int newPosition = currentPosition + diceValue.value;

    positions[tokenIndex] = newPosition;
    tokenPositions[color!] = positions;

    await _firebaseService.updateTokenPositions(color, positions);
    await _checkForCaptures(color, newPosition);
    await _updateScore(color, diceValue.value);
    await _checkCompletionStatus(color);

    if (diceValue.value == 6) {
      isWaitingForMove.value = false;
      canRollDice.value = true;
    } else {
      isWaitingForMove.value = false;
      _passTurnToNextPlayer();
    }
  }

  Future<void> _updateScore(String color, int points) async {
    final playerIndex = players.indexWhere((p) => p.color == color);
    if (playerIndex == -1) return;

    final updatedPlayer = players[playerIndex];

    updatedPlayer.score = (updatedPlayer.score ?? 0) + points;
    updatedPlayer.movesLeft = (updatedPlayer.movesLeft ?? 0) - 1;

    players[playerIndex] = updatedPlayer;
    await _firebaseService.updatePlayer(updatedPlayer);
  }

  Future<void> _checkCompletionStatus(String color) async {
    final playerIndex = players.indexWhere((p) => p.color == color);
    if (playerIndex == -1) return;

    final current = players[playerIndex];

    if (current.movesLeft! <= 0) {
      bool allCompleted = players.every((p) => p.movesLeft! <= 0);

      if (allCompleted) {
        Player? highestScorer;

        for (final p in players) {
          if (highestScorer == null || p.score! > highestScorer.score!) {
            highestScorer = p;
          }
        }

        if (highestScorer != null) {
          _declareWinner(highestScorer.uid!);
        }
      }
    }
  }

  void _checkGameState() {
    final onlinePlayers = players.where((p) => p.isOnline!).toList();

    if (onlinePlayers.length == 1 &&
        isGameStarted.value &&
        winner.value.isEmpty) {
      _declareWinner(onlinePlayers.first.uid!);
    }
  }

  void _declareWinner(int playerId) {
    _firebaseService.setWinner(playerId);
    winner.value = playerId.toString();
    _goToResultScreen();
  }

  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[_random.nextInt(chars.length)])
        .join();
  }

  void _declareLastPlayerWinner() {
    if (players == null || players!.isEmpty) return;

    for (final entry in players) {
      final player = entry;
      if (player!.isOnline! && player.missCount! < 3) {
        _declareWinner(entry.uid!);
        break;
      }
    }
  }

  void _goToResultScreen() {
    _turnTimer?.cancel();
    _waitingTimer?.cancel();

    final Map<int, int> scores = {
      for (var p in players)
        if (p.uid != null) p.uid!: p.score ?? 0,
    };

    final scoreModel = ScoreModel(
      roomId: roomId?.value ?? '',
      winner: winner.value,
      scores: scores,
    );

    _apiService.submitResult(scoreModel);
    Get.off(() => ResultScreen());
  }

  String _getAvailableColor() {
    final availableColors = ['red', 'blue', 'green', 'yellow'];
    final usedColors = players.map((p) => p.color).toList();

    return availableColors.firstWhere(
      (color) => !usedColors.contains(color),
      orElse: () => availableColors.first,
    );
  }

  Future<void> _loadTheme(String themeName) async {
    currentTheme.value = await _themeService.loadTheme(themeName);
  }

  bool isMyTurn() {
    return currentPlayer.value != null &&
        currentTurn.value == currentPlayer.value!.uid;
  }

  bool canMoveToken(int tokenIndex) {
    return isMyTurn() &&
        isWaitingForMove.value &&
        _canMoveToken(tokenIndex, diceValue.value);
  }
}

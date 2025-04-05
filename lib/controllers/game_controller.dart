
import 'dart:async';
import 'dart:math';
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
  final Rx<Player?> currentPlayer = Rx<Player?>(null);
  final RxList<Player>? player! = RxList<Player>[].obs;
  final RxString currentTurn = ''.obs;
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

  Future<void> createRoom(String name, String avatar, {String? roomId}) async {
    final db = FirebaseDatabase.instance.ref();
    final newRoomId = roomId;
    final roomRef = db.child('rooms').child(newRoomId!);
    final snapshot = await roomRef.get();

    if (snapshot.exists) {
      final playerCount = (snapshot.child('player!').value as Map?)?.length ?? 0;

      if (playerCount < 4) {
        Get.dialog(AlertDialog(
          title: const Text("Room Available"),
          content: Text("Room $newRoomId already exists with $playerCount player!. Do you want to join?"),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
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
      int uid = DateTime.now().millisecondsSinceEpoch.toString().split('').map(int.parse).reduce((a, b) => a + b);
      final playerData = {
        "uid": uid,
        "name": name,
        "avatar": avatar,
        "color": getAvailableColor([]),
        "score": 0,
        "movesLeft": 0,
        "missCount": 0,
        "isOnline": true,
      };

      await roomRef.set({
        "id": newRoomId,
        "turn": uid,
        "turnTimeLeft": 15,
        "player!": {uid: playerData},
      });

      roomId = newRoomId;
      player![uid] = Player.fromJson(playerData);

      Get.dialog(AlertDialog(
        title: const Text("Room Created"),
        content: Text("Room $newRoomId has been created."),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              listenToRoom();
            },
            child: const Text("Join Now"),
          ),
        ],
      ));
    }
  }

  String getAvailableColor(List<String> usedColors) {
    final colors = ['red', 'blue', 'green', 'yellow'];
    return colors.firstWhere((c) => !usedColors.contains(c), orElse: () => 'grey');
  }

  Future<bool> joinRoom(String roomIdToJoin, String nickname, String avatar) async {
    final String uid = DateTime.now().millisecondsSinceEpoch.toString();
    final String color = _getAvailableColor();
    final Player player = Player(uid: uid, name: nickname, avatar: avatar, color: color);
    currentPlayer.value = player;
    final success = await _firebaseService.joinRoom(roomIdToJoin, player);

    if (success) {
      _listenToRoomChanges();
      _loadTheme('default');
      return true;
    }
    return false;
  }

  void _listenToRoomChanges() {
    _firebaseService.listenToRoom().listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        if (data['player!'] != null) {
          final playersData = data['player!'] as Map<dynamic, dynamic>;
          player!!.clear();

          playersData.forEach((key, value) {
            final player = value;
            player!!= player;
          });
        }

        if (data['gameState'] != null) {
          final gameState = data['gameState'] as Map<dynamic, dynamic>;

          if (gameState['currentTurn'] != null) {
            currentTurn.value = gameState['currentTurn'].toString();
          }

          if (gameState['diceValue'] != null) {
            diceValue.value = gameState['diceValue'] as int;
          }

          if (gameState['turnStartedAt'] != null) {
            turnStartedAt.value = DateTime.fromMillisecondsSinceEpoch(gameState['turnStartedAt'] as int);
            _resetTurnTimer();
          }

          if (gameState['tokenPositions'] != null) {
            final positions = gameState['tokenPositions'] as Map<dynamic, dynamic>;
            tokenPositions.clear();

            positions.forEach((key, value) {
              final colorPositions = (value as List<dynamic>).map((e) => e as int).toList();
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
      if (player!.length == 1 && winner.value.isEmpty) {
        _declareWinner(player!.keys.first);
      } else if (player!.length > 1 && !isGameStarted.value) {
        startGame();
      }
    });
  }

  startGame() {
    if (isGameStarted.value) return;

    isGameStarted.value = true;
    final firstPlayerId = player!.keys.first;
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

    final player = player[]!;
    player.missCount++;
    _firebaseService.updatePlayer(player);

    if (player.missCount >= 3) {
      _eliminatePlayer(player.uid!);
    } else {
      _passTurnToNextPlayer();
    }
  }

  void _eliminatePlayer(String playerId) {
    if (player!.length <= 2) {
      _declareLastPlayerWinner();
    } else {
      _passTurnToNextPlayer();
    }
  }

  void _passTurnToNextPlayer() {
    final playerIds = player!.keys.toList();
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

  Future<void> moveToken(int tokenIndex) async {
    if (!isWaitingForMove.value || currentPlayer.value == null) return;

    final color = currentPlayer.value!.color;
    final positions = List<int>.from(tokenPositions[color] ?? [0, 0, 0, 0]);
    final currentPosition = positions[tokenIndex];
    int newPosition = currentPosition + diceValue.value;

    positions[tokenIndex] = newPosition;
    tokenPositions[color] = positions;

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

  Future<void> _checkForCaptures(String color, int position) async {
    if (_isSafePosition(position)) return;

    for (final otherColor in tokenPositions.keys) {
      if (otherColor == color) continue;

      final otherPositions = List<int>.from(tokenPositions[otherColor]!);

      for (int i = 0; i < otherPositions.length; i++) {
        if (otherPositions[i] == position && otherPositions[i] != 0) {
          otherPositions[i] = 0;
          tokenPositions[otherColor] = otherPositions;
          await _firebaseService.updateTokenPositions(otherColor, otherPositions);
          await _updateScore(color, 2);
        }
      }
    }
  }

  bool _isSafePosition(int position) {
    return [8, 13, 21, 26, 34, 39, 47].contains(position);
  }

  Future<void> _updateScore(String color, int points) async {
    final playerEntry = player!.entries.firstWhere(
      (entry) => entry.value.color == color,
      orElse: () => MapEntry('', Player(uid: '', name: '', avatar: '', color: '')),
    );

    if (playerEntry.key.isEmpty) return;

    final player = playerEntry.value;
    player.score += points;
    player.movesLeft--;

    player![playerEntry.key] = player;
    await _firebaseService.updatePlayer(player);
  }

  Future<void> _checkCompletionStatus(String color) async {
    final playerEntry = player!.entries.firstWhere(
      (entry) => entry.value.color == color,
      orElse: () => MapEntry('', Player(uid: '', name: '', avatar: '', color: '')),
    );

    if (playerEntry.key.isEmpty) return;

    final player = playerEntry.value;

    if (player.movesLeft <= 0) {
      bool allCompleted = true;

      for (final otherPlayer in player!.values) {
        if (otherPlayer.movesLeft > 0) {
          allCompleted = false;
          break;
        }
      }

      if (allCompleted) {
        Player? highestScorer;

        for (final p in player!.values) {
          if (highestScorer == null || p.score > highestScorer.score) {
            highestScorer = p;
          }
        }

        if (highestScorer != null) {
          _declareWinner(highestScorer.uid);
        }
      }
    }
  }

  void _checkGameState() {
    int onlinePlayers = 0;
    String lastOnlinePlayerId = '';

    for (final entry in player!.entries) {
      if (entry.value.isOnline) {
        onlinePlayers++;
        lastOnlinePlayerId = entry.key;
      }
    }

    if (onlinePlayers == 1 && isGameStarted .value && winner.value.isEmpty) {
      _declareWinner(lastOnlinePlayerId);
    }
  }

  void _declareLastPlayerWinner() {
    for (final entry in player!.entries) {
      if (entry.value.isOnline && entry.value.missCount < 3) {
        _declareWinner(entry.key);
        break;
      }
    }
  }

  void _declareWinner(String playerId) {
    _firebaseService.setWinner(playerId);
    winner.value = playerId;
    _goToResultScreen();
  }

  void _goToResultScreen() {
    _turnTimer?.cancel();
    _waitingTimer?.cancel();

    final Map<String, int> scores = {};
    for (final entry in player!.entries) {
      scores[entry.key] = entry.value.score;
    }

    final scoreModel = ScoreModel(
      roomId: roomId!.value ?? '',
      winner: winner.value,
      scores: scores,
    );

    _apiService.submitResult(scoreModel);
    Get.off(() => ResultScreen());
  }

  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  String _getAvailableColor() {
    final availableColors = ['red', 'blue', 'green', 'yellow'];
    final usedColors = player!.values.map((p) => p.color).toList();

    for (final color in availableColors) {
      if (!usedColors.contains(color)) {
        return color;
      }
    }

    return availableColors.first;
  }

  Future<void> _loadTheme(String themeName) async {
    currentTheme.value = await _themeService.loadTheme(themeName);
  }

  bool isMyTurn() {
    return currentPlayer.value != null && currentTurn.value == currentPlayer.value!.uid;
  }

  bool canMoveToken(int tokenIndex) {
    return isMyTurn() && isWaitingForMove.value && _canMoveToken(tokenIndex, diceValue.value);
  }
}
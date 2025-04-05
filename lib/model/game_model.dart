import 'dart:convert';
import 'package:aag_user/model/player_model.dart';
class Game {
  String id;
  List<Player> players;
  int currentPlayerIndex;
  int diceValue;
  bool gameStarted;
  bool gameEnded;
  String winnerId;

  Game({
    required this.id,
    required this.players,
    this.currentPlayerIndex = 0,
    this.diceValue = 0,
    this.gameStarted = false,
    this.gameEnded = false,
    this.winnerId = '',
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    List<Player> playersList = [];
    if (json['players'] != null) {
      var playersMap = json['players'] as Map<String, dynamic>;
      playersMap.forEach((key, value) {
        playersList.add(Player.fromJson(value));
      });
    }

    return Game(
      id: json['id'] ?? '',
      players: playersList,
      currentPlayerIndex: json['currentPlayerIndex'] ?? 0,
      diceValue: json['diceValue'] ?? 0,
      gameStarted: json['gameStarted'] ?? false,
      gameEnded: json['gameEnded'] ?? false,
      winnerId: json['winnerId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> playersMap = {};
    for (int i = 0; i < players.length; i++) {
      playersMap[i.toString()] = players[i].toJson();
    }

    return {
      'id': id,
      'players': playersMap,
      'currentPlayerIndex': currentPlayerIndex,
      'diceValue': diceValue,
      'gameStarted': gameStarted,
      'gameEnded': gameEnded,
      'winnerId': winnerId,
    };
  }
}

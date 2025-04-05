import 'package:firebase_database/firebase_database.dart';
import '../model/player_model.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  late DatabaseReference _roomRef;
  String? _roomId;
  String? _userId;

  // Initialize room reference
  void initRoom(String roomId, int userId) {
    _roomId = roomId;
    _userId = userId.toString();
    _roomRef = _database.ref().child('rooms').child(roomId);
    
  }

  // Create a new game room
  Future<void> createRoom(String roomId, Player player) async {
    final roomRef = _database.ref().child('rooms').child(roomId);

    // Initialize game state
    await roomRef.set({
      'player': {
        player.uid!: player.toJson(),
      },
      'gameState': {
        'currentTurn': null,
        'diceValue': 0,
        'turnStartedAt': ServerValue.timestamp,
        'tokenPositions': {
          'red': [0, 0, 0, 0],
          'blue': [0, 0, 0, 0],
          'green': [0, 0, 0, 0],
          'yellow': [0, 0, 0, 0],
        }
      },
      'winner': null,
      'createdAt': ServerValue.timestamp,
    });

    // Initialize room reference and user ID
    initRoom(roomId, player.uid!);
  }

  // Join an existing room
  Future<bool> joinRoom(String roomId, Player player) async {
    final roomSnapshot =
        await _database.ref().child('rooms').child(roomId).get();

    if (!roomSnapshot.exists) {
      return false;
    }

    // Add player to the room
    await _database
        .ref()
        .child('rooms')
        .child(roomId)
        .child('player')
        .child(player.uid!.toString())
        .set(player.toJson());

    // Initialize room reference and user ID
    initRoom(roomId, player.uid!);
    return true;
  }

  // Listen to room data changes
  Stream<DatabaseEvent> listenToRoom() {
    return _roomRef.onValue;
  }

  // Listen to specific player changes
  Stream<DatabaseEvent> listenToPlayer(String playerId) {
    return _roomRef.child('player').child(playerId).onValue;
  }

  // Listen to game state changes
  Stream<DatabaseEvent> listenToGameState() {
    return _roomRef.child('gameState').onValue;
  }

  // Update player data
  Future<void> updatePlayer(Player player) async {
    await _roomRef.child('player').child(player.uid!.toString()).update(player.toJson());
  }

  // Update player's online status
  Future<void> updatePlayerOnlineStatus(bool isOnline) async {
    if (_userId != null) {
      await _roomRef
          .child('player')
          .child(_userId!)
          .child('isOnline')
          .set(isOnline);
    }
  }

  // Roll dice and update game state
  Future<void> rollDice(int value) async {
    await _roomRef.child('gameState').update({
      'diceValue': value,
      'turnStartedAt': ServerValue.timestamp,
    });
  }

  // Update current turn
  Future<void> updateCurrentTurn(int playerId) async {
    await _roomRef.child('gameState').update({
      'currentTurn': playerId,
      'turnStartedAt': ServerValue.timestamp,
    });
  }

  // Update token positions
  Future<void> updateTokenPositions(String color, List<int> positions) async {
    await _roomRef
        .child('gameState')
        .child('tokenPositions')
        .child(color)
        .set(positions);
  }

  // Set the winner
  Future<void> setWinner(int userId) async {
    await _roomRef.child('winner').set(userId);
  }

  // Close connection when app closes
  Future<void> disconnect() async {
    if (_userId != null) {
      await updatePlayerOnlineStatus(false);
    }
  }
}

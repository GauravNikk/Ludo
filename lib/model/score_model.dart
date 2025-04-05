class ScoreModel {
  final String roomId;
  final String winner;
  final Map<int, int> scores;

  ScoreModel({
    required this.roomId,
    required this.winner,
    required this.scores,
  });

  // Convert to API JSON
  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'winner': winner,
      'scores': scores,
    };
  }
}

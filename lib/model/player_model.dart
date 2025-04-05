class Player {
   String? uid;
   String? name;
   String? avatar;
   String? color; // red, blue, green, yellow
  int? score;
  int? movesLeft;
  int? missCount;
  bool? isOnline;
  int? diceMissCount;


  Player({
     this.uid,
     this.name,
     this.avatar,
     this.color,
    this.score = 0,
    this.movesLeft = 100, // Default fixed moves
    this.missCount = 0,
    this.isOnline = true,
    this.diceMissCount = 0,
  });

  // Create from Firebase JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Unknown',
      avatar: json['avatar'] ?? '',
      color: json['color'] ?? 'red',
      score: json['score'] ?? 0,
      movesLeft: json['movesLeft'] ?? 100,
      missCount: json['missCount'] ?? 0,
      isOnline: json['isOnline'] ?? true,
      diceMissCount: json['diceMissCount'] ?? 0,
    );
  }

  // Convert to Firebase JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'avatar': avatar,
      'color': color,
      'score': score,
      'movesLeft': movesLeft,
      'missCount': missCount,
      'isOnline': isOnline,
      'diceMissCount': diceMissCount,
    };
  }

  // Create a copy with updated fields
  Player copyWith({
    String? uid,
    String? name,
    String? avatar,
    String? color,
    int? score,
    int? movesLeft,
    int? missCount,
    bool? isOnline,
    int? diceMissCount,
  }) {
    return Player(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      color: color ?? this.color,
      score: score ?? this.score,
      movesLeft: movesLeft ?? this.movesLeft,
      missCount: missCount ?? this.missCount,
      isOnline: isOnline ?? this.isOnline,
      diceMissCount: diceMissCount ?? this.diceMissCount,
    );
  }
}

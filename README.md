# Ludo
 ---

# ✅ PROJECT: Real-Time Multiplayer Ludo Game

---

## 📂 FILE STRUCTURE (GETX ARCHITECTURE)

```
lib/
├── main.dart
├── app/
│   ├── controller/
│   │   └── game_controller.dart         # Handles all logic/state
│   ├── model/
│   │   ├── player_model.dart
│   │   ├── theme_model.dart
│   │   └── score_model.dart
│   ├── service/
│   │   ├── firebase_service.dart        # Firebase Realtime DB handler
│   │   ├── api_service.dart             # Submit result to backend
│   │   └── theme_service.dart           # Load theme assets if available
│   ├── screens/
│   │   ├── game_screen.dart             # Full game board and UI
│   │   ├── waiting_screen.dart          # Shown before game starts
│   │   └── result_screen.dart           # After game ends
│   ├── widget/
│   │   ├── ludo_board.dart              # Main board rendering
│   │   ├── token_widget.dart            # Token visuals
│   │   ├── dice_widget.dart             # Dice and rolling
│   │   ├── player_info_widget.dart      # Player name, image, status
│   │   ├── theme_applier.dart           # Applies theme assets
│   │   └── player_status_badge.dart     # Online/offline + Miss indicator
assets/
└── themes/
    ├── default/
    ├── ice/
    └── fire/
```

---

## 🎯 GAME RULES

| Feature                          | Value                          |
|----------------------------------|--------------------------------|
| Min Players                      | 1                              |
| Max Players                      | 4                              |
| Turn Timer                       | 15 seconds                     |
| Max Dice Miss (Pass)             | 3 chances                      |
| Score (1 step move)              | +1 point                       |
| Score (cut token)               | +2 points                      |
| Total Moves / Player            | Fixed (e.g., 100 moves)        |
| Auto-Win (only 1 user)           | Yes, if timer ends             |

---

## 🧠 WINNER DECISION RULES

1. If **only 1 player joined** and waiting timer ends → auto-winner.
2. When **all players finish their fixed moves**:
   - Calculate highest score → winner.
3. Player with **3 missed turns** (no dice roll in time) → eliminated.
4. If only one player remains (others eliminated or left) → winner.

---

## 🎮 GAME MANAGEMENT (Realtime Firebase)

**Each game room is a Firebase node:**

```
rooms/
  {roomId}/
    players/
      {uid}/
        name: "Player1"
        avatar: "url"
        color: "red"
        score: 22
        movesLeft: 100
        missCount: 2
        isOnline: true
    gameState/
      currentTurn: {uid}
      diceValue: 5
      turnStartedAt: timestamp
      tokenPositions/
        red: [0, 2, 3, 5]
        blue: [0, 0, 1, 1]
    winner: {uid}
```

---

## ⚙️ STATE MANAGEMENT (GetX)

**Controller: `GameController`**

Tracks:

- Player list & their data (score, moves, misses)
- Current turn
- Dice rolling logic + timer
- Token movement & collision
- Score updates
- Firebase listeners to reflect updates in real-time
- Room creation/join via dialog box
- Responsive layouts for different screens (mobile/tablet/PC)

Reactive UI using `.obs`:
```dart
Rx<Player> currentPlayer = Rx<Player>();
RxMap<String, Player> players = <String, Player>{}.obs;
RxInt diceValue = 1.obs;
RxMap<String, List<int>> tokenPositions = <String, List<int>>{}.obs;
```

---

## 📱 UI SCREENS

### 🕒 Waiting Screen
- Room ID, joined players
- 15s countdown to auto-win if alone
- Responsive layout (small to large devices)

### 🎲 Game Screen
- Ludo board (theme-based or default)
- Tokens rendered as per theme or color
- Dice (only enabled for current player)
- Countdown timer (15s)
- Turn indicator
- Player info:
  - Name
  - Avatar
  - Score
  - Dice Miss Indicator (1/3)
  - Online/offline

### 🏁 Result Screen
- Winner name
- All player scores
- API call to backend to submit result

---

## 👥 PLAYER MANAGEMENT

- Each player joins using `roomId`
- Backend provides only room ID
- Player object:

```dart
class Player {
  String uid;
  String name;
  String avatar;
  String color; // red, blue, green, yellow
  int score;
  int movesLeft;
  int missCount;
  bool isOnline;

  Player copyWith(...)
  Player.fromJson(...)
  Map<String, dynamic> toJson()
}
```

- Player status (online/offline) updated via Firebase
- Device name and default avatar from https://avatar.iran.liara.run/public

---

## 📦 THEME SYSTEM (Optional)

- Base path: `assets/themes/{theme_name}/`
- If any asset missing, fallback to default visuals
- All fields are nullable (optional override)

### Overridable Theme Assets:

| Element         | File                        |
|-----------------|-----------------------------|
| Board           | `board.png(no need)`        |
| Step block      | `step_block.png`            |
| Home block      | `home_block.png`            |
| Path block      | `path_block.png`            |
| Base block      | `base_block.png`            |
| Star block      | `star.png`                  |
| Tokens          | `red_token.png`, etc.       |
| Dice Faces      | `dice_1.png` to `dice_6.png`|

**Default theme = logic-only (no assets)**

---

## 📡 BACKEND API (Submit Result)

When game ends, call:

```json
POST /submit-result
{
  "roomId": "12345",
  "winner": "uid_1",
  "scores": {
    "uid_1": 23,
    "uid_2": 18
  }
}
```

---

## 🛠️ FEATURES CHECKLIST

| Feature                           | ✅ |
|----------------------------------|----|
| Firebase Realtime Integration    | ✅ |
| GetX State Management            | ✅ |
| Dice Roll + 15s Timer            | ✅ |
| Dice Pass Count (max 3)          | ✅ |
| Score = move+cut logic           | ✅ |
| Token Movement                   | ✅ |
| Online/Offline Detection         | ✅ |
| UI sync on all players' screens  | ✅ |
| Turn management + player cycle   | ✅ |
| Room join using room ID          | ✅ |
| Theme Override (nullable)        | ✅ |
| API submission at game end       | ✅ |
| Responsive Waiting/Game Screens  | ✅ |
| Room creation/join via Dialog    | ✅ |
| Default Avatar + Device Name     | ✅ |

---

## 🧾 pubspec.yaml Essentials

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  firebase_core: ^2.25.4
  firebase_database: ^10.3.5
  firebase_auth: ^4.16.0
  http: ^1.2.1
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  lottie: ^3.1.0
  intl: ^0.18.1
```

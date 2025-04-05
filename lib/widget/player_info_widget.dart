import 'package:aag_user/model/player_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlayerInfoWidget extends StatelessWidget {
  final Player player;
  final bool isCurrentTurn;

  const PlayerInfoWidget({
    Key? key,
    required this.player,
    required this.isCurrentTurn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color borderColor = _getColorFromString(player.color);

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentTurn ? borderColor : Colors.grey.shade400,
          width: isCurrentTurn ? 3 : 1.5,
        ),
        color: Colors.white,
        boxShadow: [
          if (isCurrentTurn)
            BoxShadow(
              color: borderColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: borderColor,
            backgroundImage: player.avatar.isNotEmpty
                ? CachedNetworkImageProvider(player.avatar)
                : null,
            child: player.avatar.isEmpty
                ? Text(
                    player.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  )
                : null,
          ),

          const SizedBox(width: 10),

          // Player Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Score: ${player.score}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Moves: ${100 - player.movesLeft}/100',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Online + Missed + Turn Indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    player.isOnline! ? Icons.circle : Icons.circle_outlined,
                    size: 12,
                    color: player.isOnline! ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    player.isOnline! ? "Online" : "Offline",
                    style: TextStyle(
                      color: player.isOnline! ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Missed: ${player.diceMissCount}/3',
                style: const TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
              const SizedBox(height: 2),
              if (isCurrentTurn)
                const Text(
                  'Your Turn 🎯',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
            ],
          ),
        ],
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

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aag_user/model/player_model.dart';

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
    final borderColor = _getColorFromString(player.color!);
    final width = MediaQuery.of(context).size.width / 3;

    return SizedBox(
      height: 110,
      width: width,
      child: Container(
        // height: 120,
        width: width,
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.red,
          border: Border.all(
            color: isCurrentTurn ? borderColor : Colors.grey.shade300,
            width: isCurrentTurn ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          // boxShadow: [
          //   if (isCurrentTurn)
          //     BoxShadow(
          //       color: borderColor.withOpacity(0.3),
          //       blurRadius: 10,
          //       offset: const Offset(0, 4),
          //     ),
          // ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.amber,
              width: width / 1.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDiceSlot(), // Dice place
                  _buildAvatar(borderColor), // Profile
                ],
              ),
            ),

            /// DICE MISS (dots)

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.name ?? "Player",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: 5),
                Text(
                  '${player.movesLeft}/15',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDiceDots(player.diceMissCount!),
                SizedBox(width: 5),
                _buildOnlineStatus(player.isOnline!),
                SizedBox(width: 5),
                if (isCurrentTurn)
                  const Text(
                    '🎯',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                      fontSize: 12,
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Color borderColor) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: borderColor,
      backgroundImage: player.avatar!.isNotEmpty
          ? CachedNetworkImageProvider(player.avatar!)
          : null,
      child: player.avatar!.isEmpty
          ? Text(
              player.name![0].toUpperCase(),
              style: const TextStyle(fontSize: 20, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildDiceSlot() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey.shade100,
      ),
      child: const Icon(Icons.casino, size: 40, color: Colors.black54),
    );
  }

  Widget _buildDiceDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: i < count ? Colors.red : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildOnlineStatus(bool isOnline) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 10,
          color: isOnline ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 12,
            color: isOnline ? Colors.green : Colors.red,
          ),
        ),
      ],
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

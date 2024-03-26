import 'package:flutter/material.dart';
import '../db/player.dart';

class PlayerStatsPage extends StatelessWidget {
  final Player player;

  const PlayerStatsPage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Stats'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${player.name}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Player Rating: ${player.rating}\n',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Games Played: ${player.wins! + player.losses!}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Wins ${player.wins}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Losses: ${player.losses}',
              style: const TextStyle(fontSize: 20),
            ),
            // Add more player stats here as needed
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mrping/screens/gamehistory.dart';
import 'package:mrping/screens/leaderboard.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Dashboard"),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "Leaderboard"
              ),
              Tab(
                text: "Game History"
              )
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Leaderboard(),
            GameHistory()
          ],
        ),
      ),
    );
  }
}
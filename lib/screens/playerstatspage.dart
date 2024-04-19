
import 'package:flutter/material.dart';
import 'package:mrping/db/game.dart';
import 'package:mrping/db/mainDB.dart';
import '../db/player.dart';
import 'package:fl_chart/fl_chart.dart';

class PlayerStatsPage extends StatefulWidget {
  final Player player;
  const PlayerStatsPage({super.key, required this.player});

  @override
  State<PlayerStatsPage> createState() => _PlayerStatsPageState();
}

class _PlayerStatsPageState extends State<PlayerStatsPage> {
  late List<Game> playerGames = [];
  List<int> rChanges = [];

  void getPlayerGames() async {
    playerGames = await mainDB.instance.readPlayerGames(widget.player.name!);
    int currRating = widget.player.rating!;
    rChanges.add(currRating);

    for (int i = 0; i < playerGames.length; i++) {
      if (((playerGames[i].playerOne == widget.player.name) && (playerGames[i].playerOneScore! > playerGames[i].playerTwoScore!)) ||
      ((playerGames[i].playerTwo == widget.player.name) && (playerGames[i].playerTwoScore! > playerGames[i].playerOneScore!))){
        currRating -= playerGames[i].ratingChange!;
        rChanges.add(currRating);
      }
      else{
        currRating += playerGames[i].ratingChange!;
        rChanges.add(currRating);}
    }
    rChanges = rChanges.reversed.toList();
    setState(() {});
  }
  

  @override
  void initState() {
    super.initState();
    getPlayerGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Stats'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.player.name}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Rating',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                        ),
                        Text(
                          '${widget.player.rating}',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Wins',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                        ),
                        Text(
                          '${widget.player.wins}',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Losses',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                        ),
                        Text(
                          '${widget.player.losses}',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Point Differential',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                        ),
                        Text(
                          //put "+" if positive
                          '${widget.player.pf! - widget.player.pa! > 0 ? '+' : ''}${widget.player.pf! - widget.player.pa!}',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Points For',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                        ),
                        Text(
                          '${widget.player.pf}',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Points Against',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                        ),
                        Text(
                          '${widget.player.pa}',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),         
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Skunks',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                        ),
                        Text(
                          '${widget.player.skunks}',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Been Skunked',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                        ),
                        Text(
                          '${widget.player.skunked}',
                          style: const TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ],
                
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text("Rating Change Over Time", style: TextStyle(fontWeight: FontWeight.w200)),
              ),
              const SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 1.5,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 500,
                      verticalInterval: 5,
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d)),
                    ),
                    minX: 0,
                    maxX: 20,
                    minY: 0,
                    maxY: 2000,
                    
                    titlesData: const FlTitlesData(
                      // Hide both top and right titles
                      // rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(rChanges.length, (index) {
                          return FlSpot(index.toDouble(), double.parse(rChanges[index].toString()));
                        }),
                        barWidth: 3,
                      )
                    ]
                  )
                ),
              ),
              const Center(
                child: Text("Past 20 Games", style: TextStyle(fontWeight: FontWeight.w200)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
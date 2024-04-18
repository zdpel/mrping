import 'package:flutter/material.dart';
import '../db/game.dart';
import '../db/mainDB.dart';

class GameHistory extends StatefulWidget {
  const GameHistory({super.key});

  @override
  State<GameHistory> createState() => _GameHistoryState();
}

class _GameHistoryState extends State<GameHistory> {
  late List<Game> games = [];

  @override
  void initState(){
    super.initState();
    refreshGames();
  }

  Future refreshGames() async {
    games = await mainDB.instance.readAllGameInfo();
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          if (games.isNotEmpty)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: games.length,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: () {
                      // transition to game statistics would go here
                    },
                    child: Card(
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${games[games.length - index - 1].playerOne}',
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                                Text(
                                  'Score: ${games[games.length - index - 1].playerOneScore}',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                Text(
                                  'Rating: ${(games[games.length - index - 1].ratingChange! > 0) ? ('+${games[games.length-index-1].ratingChange}') : ('${games[games.length-index-1].ratingChange}')}',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${games[games.length - index - 1].playerTwo}',
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                                Text(
                                  'Score: ${games[games.length - index - 1].playerTwoScore}',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                Text(
                                  'Rating: ${(games[games.length - index - 1].ratingChange! > 0) ? ('${games[games.length-index-1].ratingChange!*-1}') : ('+${games[games.length-index-1].ratingChange!*-1}')}',
                                  style: const TextStyle(fontSize: 16.0),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  );
                }
              ),
            ),
          if (games.isEmpty)
            Text(
              "No games played",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
        ],
      ),
    );
  }

}
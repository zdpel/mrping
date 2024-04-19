import 'package:flutter/material.dart';
import 'package:mrping/main.dart';
import 'package:mrping/screens/playerstatspage.dart';
import 'package:provider/provider.dart';
import '../db/player.dart';


class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
    int nextID = 1;
    int myIndex = 0;

    @override
    void initState(){
      super.initState();
    }

  @override
  Widget build(BuildContext context) {
    List<Player> players = Provider.of<DatabaseInfo>(context).players;
    players.sort((a,b) => b.rating!.compareTo(a.rating as num));
    return Center(
      child: Column(
        children: <Widget>[
          const ListTile(
            leading: Text("Rank", style: TextStyle(fontSize: 15.0)),
            title: Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: Text(
                "Name",
                style: TextStyle(fontSize: 15.0),
              )
            ),
            trailing: Text("Rating", style: TextStyle(fontSize: 15.0))
          ),
          if (players.isNotEmpty)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: players.length,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                            PlayerStatsPage(player: players[index]),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            //ID ${players[index].id}
                            '${index+1}',
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Text(
                            '${players[index].name}',
                            style: const TextStyle(fontSize: 20.0),
                          )
                        ),
                        trailing: Text(
                          '${players[index].rating}',
                          style: const TextStyle(fontSize: 20.0),
                        ),
                      )
                      
                    ),
                  );
                }
              ),
            ),
          if (players.isEmpty)
            Text(
              "No db entry available",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
        ],
      ),
    );
  }
}
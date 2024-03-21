import 'package:flutter/material.dart';
import './db/mainDB.dart';
import './db/player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Mr. Ping'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Player> players = [];
  int nextID = 1;
  
  @override
  void initState(){
    super.initState();
    refreshPlayers();
  }
  void addPlayer() async {
    Player newPlayer = Player(id: nextID, name: "john", wins: 2, losses: 2, rating: 700);
    nextID++;
    await mainDB.instance.create(newPlayer);
    await refreshPlayers();
    setState(() {});
  }

  void deletePlayer() async {
    await mainDB.instance.delete(nextID-1);
    nextID--;
    await refreshPlayers();
    setState(() {}); 
  }

  Future refreshPlayers() async {
    players = await mainDB.instance.readAllPlayerInfo();
    players.sort((a,b) => b.rating!.compareTo(a.rating as num));
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.outline,
        title: Text(widget.title),
      ),
      body: Center(
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
                    return Card(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (addPlayer),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }
}

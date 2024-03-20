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
    Player newPlayer = Player(id: nextID, name: "john", wins: 2, losses: 2, rating: 500);
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
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Players:',
            ),
            if (players.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index){
                    return Text(
                      'ID ${players[index].id} NAME ${players[index].name} RATING ${players[index].rating}',
                      // players[index].name ?? "No db entry",
                      style: Theme.of(context).textTheme.headlineMedium,
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
      // floatingActionButton: Column(
      //   // Column to display multiple floating action buttons
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   crossAxisAlignment: CrossAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       onPressed: addPlayer,
      //       tooltip: 'Add Player',
      //       child: const Icon(Icons.add),
      //     ), 
      //     FloatingActionButton(
      //       onPressed: refreshPlayers,
      //       tooltip: 'Refresh Players',
      //       child: const Icon(Icons.refresh),
      //     ),
      //     FloatingActionButton(
      //       onPressed: deletePlayer,
      //       tooltip: 'Delete Players',
      //       child: const Icon(Icons.delete),
      //     ),
      //   ],
      // ),
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

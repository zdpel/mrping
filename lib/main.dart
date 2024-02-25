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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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
  
  @override
  void initState(){
    super.initState();
    refreshPlayers();
  }
  void addPlayer() async {
    Player newPlayer = Player(id: 1, name: "bob", wins: 3, losses: 1);
    await mainDB.instance.create(newPlayer);
    await refreshPlayers();
    setState(() {});
  }

  void deletePlayer() async {
    await mainDB.instance.delete(1);
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
              Text(
                players[0].name ?? "No db entry available",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            if (players.isEmpty)
              Text(
                "No db entry available",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        // Column to display multiple floating action buttons
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: addPlayer,
            tooltip: 'Add Player',
            child: const Icon(Icons.add),
          ), 
          FloatingActionButton(
            onPressed: refreshPlayers,
            tooltip: 'Refresh Players',
            child: const Icon(Icons.refresh),
          ),
          FloatingActionButton(
            onPressed: deletePlayer,
            tooltip: 'Delete Players',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}

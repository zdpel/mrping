import 'package:flutter/material.dart';
import 'package:mrping/screens/settings.dart';
import './db/player.dart';
import './db/mainDB.dart';
import 'screens/addgame.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(const MyApp());
}
//test
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
  int myIndex = 0;
  List<Widget> widgetList = const [
    Dashboard(),
    Settings(),
  ];
  
  @override
  void initState(){
    super.initState();
    refreshPlayers();
  }
  void addPlayer() async {
    Player newPlayer = Player(id: nextID, name: "john", wins: 2, losses: 2, rating: 700);
    nextID++;
    await mainDB.instance.createPlayer(newPlayer);
    await refreshPlayers();
    setState(() {});
  }

  void deletePlayer() async {
    await mainDB.instance.deletePlayer(nextID.toString());
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
      body: Center(
        child: widgetList[myIndex]
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
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
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context){
              return AddGame();
            }
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }
}

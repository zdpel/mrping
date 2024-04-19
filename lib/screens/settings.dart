import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrping/main.dart';
import 'package:mrping/screens/adminpin.dart';
import 'package:provider/provider.dart';
import '../db/mainDB.dart';
import '../db/player.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 8.0),
        child: ListView(
          children: [
            const ListTile(
              title: Text("Player Options"),
            ),
            ElevatedButton(
              onPressed : () {
                showDialog(
                  context: context,
                  builder: (context){
                    return const AddPlayer();
                  }
                );
              },
              child: const Text("Add Player"),
            ),
            const ListTile(
              title: Text("Theme Options"),
            ),
            ElevatedButton(
              onPressed: () => MyApp.of(context).changeTheme(ThemeMode.dark),
              child: const Text('Dark'),
            ),
            ElevatedButton(
              onPressed: () => MyApp.of(context).changeTheme(ThemeMode.light),
              child: const Text('Light'),
            ),
            const ListTile(
              title: Text("Admin Controls"),
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                      const AdminPin()
                  ),
                );
              }, 
              child: const Text('Admin Page')
            )
          ],
        ),
      ),
    );
  }
}

//Add Player Pop-up
class AddPlayer extends StatefulWidget {

  const AddPlayer({super.key});

  @override
  State<AddPlayer> createState() => _AddPlayerState();
}

class _AddPlayerState extends State<AddPlayer> {
  final TextEditingController _firstnameController = TextEditingController();

  final TextEditingController _lastnameController = TextEditingController();

  final TextEditingController _ratingController = TextEditingController();

  late List<Player> players = [];

  bool firstNameEmpty = false;
  bool lastNameEmpty = false;
  bool nameExists = false;

  Future<bool> checkPlayers(String name) async {
    players = await mainDB.instance.readAllPlayerInfo();
    for(var player in players){
      if(player.name == name){
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    void addPlayer(String name, int rating) async {
      //DEFAULT RATING MUST BE SET. RATING OPTION ONLY GIVEN FOR TESTING
      Player newPlayer = Player(name: name, wins: 0, losses: 0, rating: rating, pf: 0, pa: 0, skunks: 0, skunked: 0);
      await mainDB.instance.createPlayer(newPlayer);
      Provider.of<DatabaseInfo>(context, listen: false).getPlayers();
    }
    return AlertDialog(
      title: const Text('Enter Player Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstnameController,
            decoration: const InputDecoration(labelText: 'First Name'),
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(15)
            ],
          ),
          TextField(
            controller: _lastnameController,
            decoration: InputDecoration(labelText: 'Last Name', errorText: lastNameEmpty ? "Values can't be empty" : nameExists ? "Name already exists" : null),
            inputFormatters: <TextInputFormatter>[
               LengthLimitingTextInputFormatter(15)
            ],
          ),
          //DEFAULT RATING MUST BE SET. RATING OPTION ONLY GIVEN FOR TESTING. REMOVE LATER
          TextField(
            controller: _ratingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Rating'),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            bool containsName = false;
            String name = "${_firstnameController.text} ${_lastnameController.text}";
            int rating = int.tryParse(_ratingController.text) ?? 0;
            containsName = await checkPlayers(name);

            if(_firstnameController.text.isEmpty){
              setState(() {
                firstNameEmpty = true;
              });
            }
            else if(_lastnameController.text.isEmpty){
              setState(() {
                lastNameEmpty = true;
              });
            }
            else if(containsName){
              setState(() {
                firstNameEmpty = false;
                lastNameEmpty = false;
                nameExists = true;
              });
            }
            else {
              addPlayer(name, rating);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

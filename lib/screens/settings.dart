import 'package:flutter/material.dart';
import 'package:mrping/main.dart';
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
                    return AddPlayer();
                  }
                );
              },
              child: const Text("Add Player"),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context){
                    return DeletePlayer();
                  }
                );
              },
              child: const Text("Delete Player"),
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
          ],
        ),
      ),
    );
  }
}

//Add Player Pop-up
class AddPlayer extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  AddPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    void addPlayer(String name, int rating) async {
      //DEFAULT RATING MUST BE SET. RATING OPTION ONLY GIVEN FOR TESTING
      Player newPlayer = Player(name: name, wins: 2, losses: 2, rating: rating);
      await mainDB.instance.createPlayer(newPlayer);
    }
    return AlertDialog(
      title: const Text('Enter Player Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
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
          onPressed: () {
            String name = _nameController.text;
            int rating = int.tryParse(_ratingController.text) ?? 0;

            addPlayer(name, rating);
            Navigator.of(context).pop();
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

//Delete Player Pop-up
class DeletePlayer extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  DeletePlayer({super.key});

  @override
  Widget build(BuildContext context) {
    void deletePlayer(String name) async {
      await mainDB.instance.deletePlayer(name);
    }
    return AlertDialog(
      title: const Text('Enter Player Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            String name = _nameController.text;
            deletePlayer(name);
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
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
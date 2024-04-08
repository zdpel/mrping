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
  late List<String> autoCompleteData = [];
  String deletedPlayer = '';
  DeletePlayer({super.key});

  void fetchAutoCompleteData() async {
    final players = await mainDB.instance.readAllPlayerInfo();
    autoCompleteData = players.where((player) => player.name != null).map((player) => player.name!).toList();
  }

  bool validName(String name) {
    int count = autoCompleteData.where((element) => element == name).length;
    return count == 1;
  }

  void deletePlayer(String name) async {
    await mainDB.instance.deletePlayer(name);
  }

  @override
  Widget build(BuildContext context) {
    fetchAutoCompleteData();

    return AlertDialog(
      title: const Text('Enter Player Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[

          Autocomplete(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              } else {
                return autoCompleteData.where((word) => word
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              }
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onEditingComplete: onEditingComplete,
                onChanged: (value) {
                  deletedPlayer = value;
                },
                decoration: const InputDecoration(
                  hintText: "Player",
                ),
              );
            },
            onSelected: (String selection) {
              deletedPlayer = selection;
            },
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            // String name = _nameController.text;
            if(validName(deletedPlayer)) {
              deletePlayer(deletedPlayer);
              Navigator.of(context).pop();
            }
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
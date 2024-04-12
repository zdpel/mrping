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
class AddPlayer extends StatefulWidget {

  AddPlayer({super.key});

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
      Player newPlayer = Player(name: name, wins: 2, losses: 2, rating: rating);
      await mainDB.instance.createPlayer(newPlayer);
    }
    return AlertDialog(
      title: const Text('Enter Player Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _firstnameController,
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
          TextField(
            controller: _lastnameController,
            decoration: InputDecoration(labelText: 'Last Name', errorText: lastNameEmpty ? "Values can't be empty" : nameExists ? "Name already exists" : null),
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

//Delete Player Pop-up
class DeletePlayer extends StatefulWidget {
  const DeletePlayer({super.key});

  @override
  State<DeletePlayer> createState() => _DeletePlayerState();
}
class _DeletePlayerState extends State<DeletePlayer> {
  late List<String> autoCompleteData = [];
  String deletedPlayer = '';
  String? errorText = null;
  
  @override
  void initState(){
    super.initState();
    fetchAutoCompleteData();
  }

  void fetchAutoCompleteData() async {
    final players = await mainDB.instance.readAllPlayerInfo();
    autoCompleteData = players.where((player) => player.name != null).map((player) => player.name!).toList();
  }

  // Checks if a string contains only A-Z or a-z or the space character ' '
  bool isValidString(String str) {
    for(int i = 0; i < str.length; i++) {
      String char = str[i];
      int charCode = char.codeUnitAt(0);
      
      if(!((charCode >= 65 && charCode <= 90) || // uppercase letters (A-Z)
            (charCode >= 97 && charCode <= 122) || // lowercase letters (a-z)
            charCode == 32)) { // space character
        return false;
      }
    }
    return true;
  }

  String? _validateName(String value) {
    if(value.isEmpty) {
      return 'Enter a value.';
    }

    if(!isValidString(value)) {
      return 'Only letters and spaces are allowed.';
    }

    if(autoCompleteData.where((element) => element == value).length != 1) {
      return 'Name is not recognized.';
    }

    return null;
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
                  setState(() {
                    deletedPlayer = value;
                    errorText = _validateName(deletedPlayer);
                  });
                },
                decoration: InputDecoration(
                  hintText: "Player",
                  errorText: errorText,
                ),
              );
            },
            onSelected: (String selection) {
              setState(() {
                deletedPlayer = selection;
                errorText = null;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            if(errorText == null) {
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
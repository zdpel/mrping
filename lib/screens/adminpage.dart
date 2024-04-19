import 'package:flutter/material.dart';
import 'package:mrping/main.dart';
import 'package:mrping/screens/adminpin.dart';
import 'package:provider/provider.dart';
import '../db/mainDB.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Controls'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 8.0),
        child: ListView(
          children: [
            const ListTile(
              title: Text("Admin Settings"),
            ),
            ElevatedButton(
              onPressed : () {
                showDialog(
                  context: context,
                  builder: (context){
                    return const DeletePlayer();
                  }
                );
              },
              child: const Text("Delete Player"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                    CreatePIN(parentContext: context),
                  ),
                );
              }, 
              child: const Text("Reset PIN"))
          ],
        ),
      ),
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
  String? errorText;
  
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
    Provider.of<DatabaseInfo>(context, listen: false).getPlayers();
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
import 'package:flutter/material.dart';
import '../db/mainDB.dart';
import '../db/player.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(left: 10,top: 10),
        child: OutlinedButton(
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
      ),
      
    );
  }
}

class AddPlayer extends StatefulWidget {
  const AddPlayer({super.key});

  @override
  State<AddPlayer> createState() => _AddPlayerState();
}

//Add player pop-up
class _AddPlayerState extends State<AddPlayer> {
  int nextID = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ratingController.dispose();
    super.dispose();
  }
  void addPlayer(String name, int rating) async {
    //DEFAULT RATING MUST BE SET. RATING OPTION ONLY GIVEN FOR TESTING
    Player newPlayer = Player(name: name, wins: 2, losses: 2, rating: rating);
    await mainDB.instance.create(newPlayer);
    nextID++;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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

            addPlayer(name,rating);
            
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
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



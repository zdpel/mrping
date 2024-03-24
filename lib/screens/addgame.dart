import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddGame extends StatelessWidget {
  final TextEditingController _firstPlayerController = TextEditingController();
  final TextEditingController _secondPlayerController = TextEditingController();
  final TextEditingController _firstScoreController = TextEditingController();
  final TextEditingController _secondScoreController = TextEditingController();
  AddGame({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Game Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _firstPlayerController,
            decoration: const InputDecoration(labelText: 'Player 1'),
          ),
          TextField(
            controller: _secondPlayerController,
            decoration: const InputDecoration(labelText: 'Player 2'),
          ),
          //DEFAULT RATING MUST BE SET. RATING OPTION ONLY GIVEN FOR TESTING. REMOVE LATER
          TextField(
            controller: _firstScoreController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(labelText: 'Player 1 Score'),
          ),
          TextField(
            controller: _secondScoreController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(labelText: 'Player 2 Score'),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/game.dart';
import '../db/mainDB.dart';

class AddGame extends StatelessWidget {
  final TextEditingController _playerOneController = TextEditingController();
  final TextEditingController _playerTwoController = TextEditingController();
  final TextEditingController _playerOneScoreController = TextEditingController();
  final TextEditingController _playerTwoScoreController = TextEditingController();
  int gameIndex = 0;

  AddGame({super.key});

  @override
  Widget build(BuildContext context) {
    bool validGameScore(int one, int two) {
      // skunk scores are 7-0 and 11-1

      if(one < 0 || two < 0) {
        return false;
      }

      if((one > 21 || two > 21) && ((one - two).abs() != 2)) {
        return false;
      }

      if((one == 7 && two == 0) || (one == 0 && two == 7)) {
        return true;
      }

      if((one == 11 && two == 1) || (one == 1 && two == 11)) {
        return true;
      }

      return true;
    }

    Future<bool> addGame(String playerOne, int playerOneScore, String playerTwo, int playerTwoScore) async {
      if(validGameScore(playerOneScore, playerTwoScore)) {
        Game newGame = Game(playerOne: playerOne, playerOneScore: playerOneScore, playerTwo: playerTwo, playerTwoScore: playerTwoScore);
        await mainDB.instance.createGame(newGame);

        return true;
      }

      return false;
    }

    return AlertDialog(
      title: const Text('Enter Game Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _playerOneController,
            decoration: const InputDecoration(labelText: 'Player 1'),
          ),
          TextField(
            controller: _playerOneScoreController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(labelText: 'Player 1 Score'),
          ),
          TextField(
            controller: _playerTwoController,
            decoration: const InputDecoration(labelText: 'Player 2'),
          ),
          //DEFAULT RATING MUST BE SET. RATING OPTION ONLY GIVEN FOR TESTING. REMOVE LATER
          TextField(
            controller: _playerTwoScoreController,
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
            String playerOne = _playerOneController.text;
            int playerOneScore = int.tryParse(_playerOneScoreController.text) ?? 0;
            String playerTwo = _playerTwoController.text;
            int playerTwoScore = int.tryParse(_playerTwoScoreController.text) ?? 0;

            addGame(playerOne, playerOneScore, playerTwo, playerTwoScore);
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
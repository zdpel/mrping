import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/game.dart';
import '../db/mainDB.dart';

class AddGame extends StatefulWidget {
  const AddGame({super.key});

  @override
  State<AddGame> createState() => _AddGameState();
}

class _AddGameState extends State<AddGame> {
  final TextEditingController _playerOneController = TextEditingController();
  final TextEditingController _playerTwoController = TextEditingController();
  final TextEditingController _playerOneScoreController = TextEditingController();
  final TextEditingController _playerTwoScoreController = TextEditingController();

  int gameIndex = 0;
  bool invalidScore = false;
  String invalidScoreMessage = "Invalid Score";

  @override
  Widget build(BuildContext context) {
    bool validGameScore(int one, int two) {
      //Normal game to 21
      if((one == 21 && two < 21 && two >= 0) || (two == 21 && one < 21 && one >= 0)){
        return true;
      }
      //Game more than 21
      else if((one > 21 || two > 21) && ((one - two).abs() == 2)) {
        return true;
      }
      //Normal game to 11
      if((one == 11 && two < 11 && two >= 0) || (two == 11 && one < 11 && one >= 0)){
        return true;
      }
      //7-0 skunk
      else if((one == 7 && two == 0) || (one == 0 && two == 7)) {
        return true;
      }
      //11-1 skunk
      else if((one == 11 && two == 1) || (one == 1 && two == 11)) {
        return true;
      }
      return false;
    }

    void addGame(String playerOne, int playerOneScore, String playerTwo, int playerTwoScore) async {
        Game newGame = Game(playerOne: playerOne, playerOneScore: playerOneScore, playerTwo: playerTwo, playerTwoScore: playerTwoScore);
        await mainDB.instance.createGame(newGame);
    }

    return AlertDialog(
      title: const Text('Enter Game Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Flexible(
                child: TextField(
                  controller: _playerOneController,
                  decoration: const InputDecoration(labelText: 'Player 1'),
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _playerOneScoreController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(labelText: 'Score'),
                ),
              ),
            ]
          ),
          Row(
            children: [
              Flexible(
                child: TextField(
                  controller: _playerTwoController,
                  decoration: const InputDecoration(labelText: 'Player 2'),
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _playerTwoScoreController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(labelText: 'Score'),
                ),
              ),
            ]
          ),
          const SizedBox(height: 10),
          Builder(builder: (context){
            if(invalidScore){
              return Text(invalidScoreMessage, style: const TextStyle(color: Colors.red));
            } else{
              return const Text("");
            }
          })
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            String playerOne = _playerOneController.text;
            int playerOneScore = int.tryParse(_playerOneScoreController.text) ?? 0;
            String playerTwo = _playerTwoController.text;
            int playerTwoScore = int.tryParse(_playerTwoScoreController.text) ?? 0;

            if(validGameScore(playerOneScore, playerTwoScore)){
              addGame(playerOne, playerOneScore, playerTwo, playerTwoScore);
              Navigator.of(context).pop();
            }
            else {
              setState(() {
                invalidScore = true;
              });
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
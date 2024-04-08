import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/mainDB.dart';
import '../db/game.dart';

class AddGame extends StatefulWidget {
  const AddGame({super.key});

  @override
  State<AddGame> createState() => _AddGameState();
}

class _AddGameState extends State<AddGame> {
  final TextEditingController _playerOneScoreController = TextEditingController();
  final TextEditingController _playerTwoScoreController = TextEditingController();

  bool isLoading = false;
  String playerOne = '';
  String playerTwo = '';

  late List<String> autoCompleteData = [];
  
  @override
  void initState(){
    super.initState();
    fetchAutoCompleteData();
  }

  Future fetchAutoCompleteData() async {
    setState(() {
      isLoading = true;
    });

    final players = await mainDB.instance.readAllPlayerInfo();
    
    setState(() {
      isLoading = false;
      autoCompleteData = players.where((player) => player.name != null).map((player) => player.name!).toList();
    });
  }

  bool validNames(String one, String two) {
    int countOne = autoCompleteData.where((element) => element == one).length;
    int countTwo = autoCompleteData.where((element) => element == two).length;

    return countOne == 1 && countTwo == 1;
  }

  bool validGameScore(int one, int two) {
    // skunk scores are 7-0 and 11-1
    if((one == 7 && two == 0) || (one == 0 && two == 7)) {
      return true;
    } else if((one == 11 && two == 1) || (one == 1 && two == 11)) {
      return true;
    }

    // if the game is not a skunk, at least one person must reach at least 21
    if(one < 21 && two < 21) {
      return false;
    }

    // if either score is greater than 21, then the game went OT and must have a difference of 2 (win by 2)
    if((one > 21 || two > 21) && ((one - two).abs() != 2)) {
      return false;
    }

    // if either score is 21 or greater, they cannot be equal
    if((one >= 21 || two >= 21) && (one == two)) {
      return false;
    }

    // negative numbers should not be possible, but this handles it just in case
    if(one < 0 || two < 0) {
      return false;
    }

    // otherwise return true
    return true;
  }

  void addGame(String playerOne, int playerOneScore, String playerTwo, int playerTwoScore) async {
    Game newGame = Game(playerOne: playerOne, playerOneScore: playerOneScore, playerTwo: playerTwo, playerTwoScore: playerTwoScore);
    await mainDB.instance.createGame(newGame);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Game Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  playerOne = value;
                },
                decoration: const InputDecoration(
                  hintText: "Player 1",
                ),
              );
            },
            onSelected: (String selection) {
              playerOne = selection;
            },
          ),

          TextField(
            controller: _playerOneScoreController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              hintText: _playerOneScoreController.text.isEmpty ? 'Player 1 Score' : '',
            ),
          ),

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
                  playerTwo = value;
                },
                decoration: const InputDecoration(
                  hintText: "Player 2",
                ),
              );
            },
            onSelected: (String selection) {
              playerTwo = selection;
            },
          ),

          TextField(
            controller: _playerTwoScoreController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              hintText: _playerTwoScoreController.text.isEmpty ? 'Player 2 Score' : '',
            ),
          ),

        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            int playerOneScore = int.tryParse(_playerOneScoreController.text) ?? 0;
            int playerTwoScore = int.tryParse(_playerTwoScoreController.text) ?? 0;

            if(validGameScore(playerOneScore, playerTwoScore) && validNames(playerOne, playerTwo)) {
              addGame(playerOne, playerOneScore, playerTwo, playerTwoScore);
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
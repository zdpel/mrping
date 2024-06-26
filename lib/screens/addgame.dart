import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrping/main.dart';
import 'package:provider/provider.dart';
import '../db/mainDB.dart';
import '../db/game.dart';
import '../db/player.dart';
import 'dart:math';

class AddGame extends StatefulWidget {
  const AddGame({super.key});

  @override
  State<AddGame> createState() => _AddGameState();
}

class _AddGameState extends State<AddGame> {
  final TextEditingController _playerOneScoreController = TextEditingController();
  final TextEditingController _playerTwoScoreController = TextEditingController();
  late List<String> autoCompleteData = [];

  String playerOne = '';
  int? playerOneScore;
  String? playerOneNameError;
  String? playerOneScoreError;
  int playerOneRating = 0;
  String playerTwo = '';
  int? playerTwoScore;
  String? playerTwoNameError;
  String? playerTwoScoreError;
  int playerTwoRating = 0;

  @override
  void initState(){
    super.initState();
    fetchAutoCompleteData();
  }

  Future fetchAutoCompleteData() async {
    final players = await mainDB.instance.readAllPlayerInfo();
    
    setState(() {
      autoCompleteData = players.where((player) => player.name != null).map((player) => player.name!).toList();
    });
  }

  // Checks if a string contains only A-Z or a-z or the space character ' '
  bool _isValidString(String str) {
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
      setState(() {
        (playerOne.isEmpty) ? playerOneNameError = 'Enter a value' : null;
        (playerTwo.isEmpty) ? playerTwoNameError = 'Enter a value' : null;
      });
      return 'Enter a value';
    }

    if(!_isValidString(value)) {
      return 'Only letters and spaces are allowed';
    }

    if(autoCompleteData.where((element) => element == value).length != 1) {
      return 'Name is not recognized';
    }

    if(playerOne == playerTwo) {
      return 'Names may only be used once';
    }

    return null;
  }

  bool _validateScoreOnAdd() {
    if(playerOneScore == null || playerTwoScore == null) {
      setState(() {
        playerOneScoreError = (playerOneScoreError == 'Invalid score') ? 'Invalid score' : (playerOneScore == null) ? 'Enter a value' : null;
        playerTwoScoreError = (playerTwoScoreError == 'Invalid score') ? 'Invalid score' : (playerTwoScore == null) ? 'Enter a value' : null;
      });

      return false;
    }

    return (playerOneScoreError == null && playerTwoScoreError == null) ? true : false;
  }

  String? _validateScoreOnType(int player) {
    debugPrint("playerOneScore: $playerOneScore");
    debugPrint("plaerTwoScore: $playerTwoScore");

    // if empty score tell user to enter a value in the correct field
    if(playerOneScore == null) {
      return (player == 1) ? 'Enter a value' : null;
    }

    if(playerTwoScore == null) {
      return (player == 2) ? 'Enter a value' : null;
    }

    // if either value is null we cannot proceed to checking integer values - exit here
    if(playerOneScore == null || playerTwoScore == null) {
      return null;
    }

    // get integer values now that both scoreOne and scoreTwo are not empty
    int scoreOne = playerOneScore!;
    int scoreTwo = playerTwoScore!;

    // 0-7 skunk score
    if((scoreOne == 0 && scoreTwo == 7) || (scoreOne == 7 && scoreTwo == 0)) {
      playerOneScoreError = null;
      playerTwoScoreError = null;

      return null;
    }

    // 1-11 skunk score
    if((scoreOne == 1 && scoreTwo == 11) || (scoreOne == 11 && scoreTwo == 1)) {
      playerOneScoreError = null;
      playerTwoScoreError = null;

      return null;
    }

    // both scoreOne and scoreTwo are [2, 21] and exactly ONE is equal to 21
    if(scoreOne >= 2 && scoreOne <= 21 && scoreTwo >= 2 && scoreTwo <= 21 && ((scoreOne == 21) ^ (scoreTwo == 21))) {
      playerOneScoreError = null;
      playerTwoScoreError = null;

      return null;
    }

    // OT scores must have a difference of 2
    if((scoreOne > 21 || scoreTwo > 21) && ((scoreOne - scoreTwo).abs() == 2)) {
      playerOneScoreError = null;
      playerTwoScoreError = null;

      return null;
    }

    // the score is invalid - display both scores as invalid
    return 'Invalid score';
  }

  bool _validInput() {
    bool validPlayerOneName = (_validateName(playerOne) == null);
    bool validPlayerTwoName = (_validateName(playerTwo) == null);
    bool validScore = _validateScoreOnAdd();

    return validPlayerOneName && validPlayerTwoName && validScore;
  }

  Future<bool> _addGame(String playerOne, int playerOneScore, String playerTwo, int playerTwoScore) async {
    int ratingChange = await _updatePlayerRatings();

    Game newGame = Game(playerOne: playerOne, playerOneScore: playerOneScore, playerTwo: playerTwo, playerTwoScore: playerTwoScore, ratingChange: ratingChange.abs());
    await mainDB.instance.createGame(newGame);

    Provider.of<DatabaseInfo>(context, listen: false).getGames();
    Provider.of<DatabaseInfo>(context, listen: false).getPlayers();
    return true;
  }

  double _calculateExpectedOutcome(int playerRating, int opponentRating) {
    // constant c-factor
    double c = 400.0;

    // calculate Q values for both players
    num qA = pow(10, playerRating / c);
    num qB = pow(10, opponentRating / c);

    // calculate expected outcome for player A
    return qA / (qA + qB);
  }

  int _calculateRatingChange(int playerRating, int playerPoints, int opponentRating, int opponentPoints) {
    debugPrint("Calculating rating change for the following values");
    debugPrint("playerRating: $playerRating");
    debugPrint("playerPoints: $playerPoints");
    debugPrint("opponentRating: $opponentRating");
    debugPrint("opponentPoints: $opponentPoints");

    // rating difference weight
    double baseFactor = 64.0;

    // point difference weight
    double bonusFactor = 12.0;

    // outcome of the match
    int actualOutcome = (playerPoints > opponentPoints) ? 1 : 0;

    // expected outcome of the match
    double expectedOutcome = _calculateExpectedOutcome(playerRating, opponentRating);
    debugPrint("expectedOutcome: $expectedOutcome");

    // calculate the base rating change based on the rating difference
    double base = baseFactor * (actualOutcome - expectedOutcome);
    debugPrint("base:  $base");

    // calculate the bonus rating change based on the point difference
    double bonus = bonusFactor * ((playerPoints - opponentPoints) / (playerPoints + opponentPoints));
    debugPrint("bonus: $bonus");

    // calculate the rating change for the match
    int ratingChange = (base + bonus).round();

    return ratingChange;
  }

  Future<int> _updatePlayerRatings() async {
    Player pPlayerOne = await mainDB.instance.readPlayerInfo(playerOne);
    Player pPlayerTwo = await mainDB.instance.readPlayerInfo(playerTwo);

    bool playerOneSkunked = false;
    bool playerTwoSkunked = false;

    if(playerOneScore == 0 && playerTwoScore == 7 || playerOneScore == 1 && playerTwoScore == 11) {
      playerOneSkunked = true;
    } 
    else if(playerOneScore == 7 && playerTwoScore == 0 || playerOneScore == 11 && playerTwoScore == 1) {
      playerTwoSkunked = true;
    }

    playerOneRating = pPlayerOne.rating!;
    playerTwoRating = pPlayerTwo.rating!;

    int ratingChange = _calculateRatingChange(playerOneRating, playerOneScore!, playerTwoRating, playerTwoScore!);

    int winner = (playerOneScore! > playerTwoScore!) ? 1 : 0;

    Player pPlayerOneUpdated = pPlayerOne.copy(
      wins: (winner == 1) ? (pPlayerOne.wins! + 1) : pPlayerOne.wins,
      losses: (winner == 0) ? (pPlayerOne.losses! + 1) : pPlayerOne.losses,
      rating: pPlayerOne.rating! + ratingChange,
      pf: pPlayerOne.pf! + playerOneScore!,
      pa: pPlayerOne.pa! + playerTwoScore!,
      skunks: (playerTwoSkunked) ? (pPlayerOne.skunks! + 1) : pPlayerOne.skunks,
      skunked: (playerOneSkunked) ? (pPlayerOne.skunked! + 1) : pPlayerOne.skunked,
    );
    Player pPlayerTwoUpdated = pPlayerTwo.copy(
      wins: (winner == 1) ? pPlayerTwo.wins : (pPlayerTwo.wins! + 1),
      losses: (winner == 0) ? pPlayerTwo.losses : (pPlayerTwo.losses! + 1),
      rating: pPlayerTwo.rating! - ratingChange,
      pf: pPlayerTwo.pf! + playerTwoScore!,
      pa: pPlayerTwo.pa! + playerOneScore!,
      skunks: (playerOneSkunked) ? (pPlayerTwo.skunks! + 1) : pPlayerTwo.skunks,
      skunked: (playerTwoSkunked) ? (pPlayerTwo.skunked! + 1) : pPlayerTwo.skunked,
    );

    mainDB.instance.updatePlayer(pPlayerOneUpdated);
    mainDB.instance.updatePlayer(pPlayerTwoUpdated);

    return ratingChange;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Game Details'),
      content: SingleChildScrollView(
        child: Column(
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
                    setState(() {
                      playerOne = value;
                      playerOneNameError = _validateName(playerOne);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Player 1",
                    errorText: playerOneNameError,
                  ),
                );
              },
              onSelected: (String selection) {
                setState(() {
                  playerOne = selection;
                  playerOneNameError = _validateName(playerOne);
                });
              },
            ),
        
            TextField(
              controller: _playerOneScoreController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2)
              ],
              onChanged: (value) {
                setState(() {
                  if(value.isEmpty) {
                    playerOneScoreError = 'Enter a value.';
                  } else {
                    playerOneScore = int.parse(value);
                    playerOneScoreError = _validateScoreOnType(1);
                  }
                });
              },
              decoration: InputDecoration(
                hintText: _playerOneScoreController.text.isEmpty ? 'Player 1 Score' : '',
                errorText: playerOneScoreError,
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
                    setState(() {
                      playerTwo = value;
                      playerTwoNameError = _validateName(playerTwo);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Player 2",
                    errorText: playerTwoNameError,
                  ),
                );
              },
              onSelected: (String selection) {
                setState(() {
                  playerTwo = selection;
                  playerTwoNameError = _validateName(playerTwo);
                });
              },
            ),
        
            TextField(
              controller: _playerTwoScoreController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2)
              ],
              onChanged: (value) {
                setState(() {
                  if(value.isEmpty) {
                    playerTwoScoreError = 'Enter a value.';
                  } else {
                    playerTwoScore = int.parse(value);
                    playerTwoScoreError = _validateScoreOnType(2);
                  }
                });
              },
              decoration: InputDecoration(
                hintText: _playerTwoScoreController.text.isEmpty ? 'Player 2 Score' : '',
                errorText: playerTwoScoreError, 
              ),
            ),
        
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            if(_validInput()) {
              await _addGame(playerOne, playerOneScore!, playerTwo, playerTwoScore!);

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
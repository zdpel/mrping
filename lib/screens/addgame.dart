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
  late List<String> autoCompleteData = [];

  String playerOne = '';
  String? playerOneScore;
  String? playerOneNameError;
  String? playerOneScoreError;
  String playerTwo = '';
  String? playerTwoScore;
  String? playerTwoNameError;
  String? playerTwoScoreError;
  
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
      setState(() {
        (playerOne.isEmpty) ? playerOneNameError = 'Enter a value' : null;
        (playerTwo.isEmpty) ? playerTwoNameError = 'Enter a value' : null;
      });
      return 'Enter a value.';
    }

    if(!isValidString(value)) {
      return 'Only letters and spaces are allowed.';
    }

    if(autoCompleteData.where((element) => element == value).length != 1) {
      return 'Name is not recognized.';
    }

    if(playerOne == playerTwo) {
      return 'Names may only be used once.';
    }

    return null;
  }

  String? _validateScore() {
    // don't validate until both scores have been entered
    if(playerOneScore == null || playerTwoScore == null) {
      setState(() {
        (playerOneScore == null) ? playerOneScoreError = 'Enter a value.' : playerOneScoreError = null;
        (playerTwoScore == null) ? playerTwoScoreError = 'Enter a value.' : playerTwoScoreError = null;
      });
      return null;
    }

    if(playerOneScore == '' || playerTwoScore == '') {
      return null;
    }

    int scoreOne = int.parse(playerOneScore!);
    int scoreTwo = int.parse(playerTwoScore!);

    // skunk scores are 7-0 and 11-1
    if((scoreOne == 7 && scoreTwo == 0) || (scoreOne == 0 && scoreTwo == 7)) {
      return null;
    } else if((scoreOne == 11 && scoreTwo == 1) || (scoreOne == 1 && scoreTwo == 11)) {
      return null;
    }

    // if the game is not a skunk, at least one person must reach at least 21
    if(scoreOne < 21 && scoreTwo < 21) {
      return 'Invalid score.';
    }

    // if either score is greater than 21, then the game went OT and must have a difference of 2 (win by 2)
    if((scoreOne > 21 || scoreTwo > 21) && ((scoreOne - scoreTwo).abs() != 2)) {
      return 'Invalid score.';
    }

    // if either score is 21 or greater, they cannot be equal
    if((scoreOne >= 21 || scoreTwo >= 21) && (scoreOne == scoreTwo)) {
      return 'Invalid score.';
    }

    // negative numbers should not be possible, but this handles it just in case
    if(scoreOne < 0 || scoreTwo < 0) {
      return 'Invalid score.';
    }

    playerOneScoreError = null;
    playerTwoScoreError = null;

    return null;
  }

  bool _validInput() {
    return _validateName(playerOne) == null &&
        _validateName(playerTwo) == null &&
        _validateScore() == null;
  }

  void _addGame(String playerOne, int playerOneScore, String playerTwo, int playerTwoScore) async {
    Game newGame = Game(playerOne: playerOne, playerOneScore: playerOneScore, playerTwo: playerTwo, playerTwoScore: playerTwoScore);
    await mainDB.instance.createGame(newGame);
  }
  
  // // START RANKING ALGORITHM 
  // final double kFactor = 32; // The K-factor determines the sensitivity of the rating update

  // // Calculate expected score based on rank difference
  // double calculateExpectedScore(int playerRank, int opponentRank) {
  //   return 1 / (1 + pow(10, ((opponentRank - playerRank) / 400)));
  // }

  // // Update player rank based on actual and expected scores
  // int updateRank(int playerRank, int opponentRank, double playerScore, double opponentScore) {
  //   double expectedScore = calculateExpectedScore(playerRank, opponentRank);
  //   double scoreDifference = playerScore - expectedScore;
  //   return (playerRank + (kFactor * scoreDifference)).toInt();
  // }

  // // Ranking algorithm function
  // Tuple<int, int> rankingAlgorithm(int playerOneRank, double playerOneScore, int playerTwoRank, double playerTwoScore) {
  //   int newPlayerOneRank = updateRank(playerOneRank, playerTwoRank, playerOneScore, playerTwoScore);
  //   int newPlayerTwoRank = updateRank(playerTwoRank, playerOneRank, playerTwoScore, playerOneScore);
  //   return Tuple(newPlayerOneRank, newPlayerTwoRank);
  // }
  // // END RANKING ALGORITHM


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
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                setState(() {
                  if(value.isEmpty) {
                    playerOneScore = '';
                    playerOneScoreError = 'Enter a value.';
                  } else {
                    playerOneScore = value;
                    playerOneScoreError = _validateScore();
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
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                setState(() {
                  if(value.isEmpty) {
                    playerTwoScore = '';
                    playerTwoScoreError = 'Enter a value.';
                  } else {
                    playerTwoScore = value;
                    playerTwoScoreError = _validateScore();
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
          onPressed: () {
            if(_validInput()) {
              _addGame(playerOne, int.parse(playerOneScore!), playerTwo, int.parse(playerTwoScore!));
              
              // update player ranking

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

class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple(this.item1, this.item2);
}

// Prototype Review Comments

// Name collisions for new players
// Overflow to limit number of players
// Condensed player dropdown on leaderboard

const String tableGames = 'games';

class GameFields {
  static final List<String> values = [
    id, playerOne, playerTwo, playerOneScore, playerTwoScore, ratingChange
  ];

  static const String id = '_id';
  static const String playerOne = 'playerOne';
  static const String playerTwo = 'playerTwo';
  static const String playerOneScore = 'playerOneScore';
  static const String playerTwoScore = 'playerTwoScore';
  static const String ratingChange = 'ratingChange';
}

class Game {
  final int? id;
  final String? playerOne;
  final String? playerTwo;
  final int? playerOneScore;
  final int? playerTwoScore;
  final int? ratingChange;
  
  const Game({
    this.id,
    this.playerOne,
    this.playerTwo,
    this.playerOneScore,
    this.playerTwoScore,
    this.ratingChange
  });

  Game copy({
    int? id,
    String? playerOne,
    String? playerTwo,
    int? playerOneScore,
    int? playerTwoScore,
    int? ratingChange,
  }) =>
    Game(
      id: id ?? this.id,
      playerOne: playerOne ?? this.playerOne,
      playerTwo: playerTwo ?? this.playerTwo,
      playerOneScore: playerOneScore ?? this.playerOneScore,
      playerTwoScore: playerTwoScore ?? this.playerTwoScore,
      ratingChange: ratingChange ?? this.ratingChange,
    );
  
  //converting json retrieved from db to Player object
  static Game fromJson(Map<String,Object?> json) => Game(
    id: json[GameFields.id] as int?,
    playerOne: json[GameFields.playerOne] as String,
    playerTwo: json[GameFields.playerTwo] as String,
    playerOneScore: json[GameFields.playerOneScore] as int,
    playerTwoScore: json[GameFields.playerTwoScore] as int,
    ratingChange: json[GameFields.ratingChange] as int,
  );


  Map<String, Object?> toJson() => {
    GameFields.id: id,
    GameFields.playerOne: playerOne,
    GameFields.playerTwo: playerTwo,
    GameFields.playerOneScore: playerOneScore, 
    GameFields.playerTwoScore: playerTwoScore, 
    GameFields.ratingChange: ratingChange,
  };
}

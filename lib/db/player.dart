const String tablePlayers = 'players';

class PlayerFields {
  static final List<String> values = [
    id, name, wins, losses, rating
  ];

  static const String id = '_id';
  static const String name = 'name';
  static const String wins = 'wins';
  static const String losses = 'losses';
  static const String rating = 'rating';
}

class Player {
  final int? id;
  final String? name;
  final int? wins;
  final int? losses;
  final int? rating;
  
  const Player({
    this.id,
    this.name,
    this.wins,
    this.losses,
    this.rating
  });

  Player copy({
    int? id,
    String? name,
    int? wins,
    int? losses,
    int? rating
  }) =>
    Player(
      id: id ?? this.id,
      name: name ?? this.name,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      rating: rating ?? this.rating,
    );
  
  //converting json retrieved from db to Player object
  static Player fromJson(Map<String,Object?> json) => Player(
    id: json[PlayerFields.id] as int?,
    name: json[PlayerFields.name] as String,
    wins: json[PlayerFields.wins] as int,
    losses: json[PlayerFields.losses] as int,
    rating: json[PlayerFields.rating] as int
  );


  Map<String, Object?> toJson() => {
    PlayerFields.id: id,
    PlayerFields.name: name,
    PlayerFields.wins: wins,
    PlayerFields.losses: losses,
    PlayerFields.rating: rating,
  };
}

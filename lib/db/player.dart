final String tablePlayers = 'players';

class PlayerFields {
  static final List<String> values = [
    id, name, wins, losses
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String wins = 'wins';
  static final String losses = 'losses';
}

class Player {
  final int? id;
  final String? name;
  final int? wins;
  final int? losses;
  
  const Player({
    this.id,
    this.name,
    this.wins,
    this.losses

  });

  Player copy({
    int? id,
    String? name,
    int? wins,
    int? losses,
  }) =>
    Player(
      id: id ?? this.id,
      name: name ?? this.name,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
    );
  
  //converting json retrieved from db to Player object
  static Player fromJson(Map<String,Object?> json) => Player(
    id: json[PlayerFields.id] as int?,
    name: json[PlayerFields.name] as String,
    wins: json[PlayerFields.wins] as int,
    losses: json[PlayerFields.losses] as int,
  );


  Map<String, Object?> toJson() => {
    PlayerFields.id: id,
    PlayerFields.name: name,
    PlayerFields.wins: wins,
    PlayerFields.losses: losses,
  };
}

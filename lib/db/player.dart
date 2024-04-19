const String tablePlayers = 'players';

class PlayerFields {
  static final List<String> values = [
    id, name, wins, losses, rating, pf, pa, skunks, skunked
  ];

  static const String id = '_id';
  static const String name = 'name';
  static const String wins = 'wins';
  static const String losses = 'losses';
  static const String rating = 'rating';
  static const String pf = 'pf';
  static const String pa = 'pa';
  static const String skunks = 'skunks';
  static const String skunked = 'skunked';
}

class Player {
  final int? id;
  final String? name;
  final int? wins;
  final int? losses;
  final int? rating;
  final int? pf;
  final int? pa;
  final int? skunks;
  final int? skunked;
  
  const Player({
    this.id,
    this.name,
    this.wins,
    this.losses,
    this.rating,
    this.pf,
    this.pa,
    this.skunks,
    this.skunked,
  });

  Player copy({
    int? id,
    String? name,
    int? wins,
    int? losses,
    int? rating,
    int? pf,
    int? pa,
    int? skunks,
    int? skunked,
  }) =>
    Player(
      id: id ?? this.id,
      name: name ?? this.name,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      rating: rating ?? this.rating,
      pf: pf ?? this.pf,
      pa: pa ?? this.pa,
      skunks: skunks ?? this.skunks,
      skunked: skunked ?? this.skunked,
    );
  
  //converting json retrieved from db to Player object
  static Player fromJson(Map<String,Object?> json) => Player(
    id: json[PlayerFields.id] as int?,
    name: json[PlayerFields.name] as String,
    wins: json[PlayerFields.wins] as int,
    losses: json[PlayerFields.losses] as int,
    rating: json[PlayerFields.rating] as int,
    pf: json[PlayerFields.pf] as int,
    pa: json[PlayerFields.pa] as int,
    skunks: json[PlayerFields.skunks] as int,
    skunked: json[PlayerFields.skunked] as int,
  );


  Map<String, Object?> toJson() => {
    PlayerFields.id: id,
    PlayerFields.name: name,
    PlayerFields.wins: wins,
    PlayerFields.losses: losses,
    PlayerFields.rating: rating,
    PlayerFields.pf: pf,
    PlayerFields.pa: pa,
    PlayerFields.skunks: skunks,
    PlayerFields.skunked: skunked,
  };
}

import 'dart:async';

//import 'package:flutter/widgets.dart';
import 'package:mrping/db/player.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//main database class to interact with player db
//includes initializing db, creating db, creating player table in db, adding players to table
class mainDB{
  static final mainDB instance = mainDB._init();

  static Database? _database;

  mainDB._init();

  Future<Database> get database async {
    //if database exists, return it
    if (_database != null) return _database!;

    //if database does not exist, initialize db
    _database = await _initDB('players.db');
    return _database!;
  }

  //initializing db
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //creating table with values from player.dart class
  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final integerType = 'INTEGER NOT NULL';
    final textType = 'TEXT NOT NULL';

  //sql create query
    await db.execute('''CREATE TABLE $tablePlayers (
      ${PlayerFields.id} $idType,
      ${PlayerFields.name} $textType,
      ${PlayerFields.wins} $integerType,
      ${PlayerFields.losses} $integerType,
      ${PlayerFields.rating} $integerType
    )''');
  }

  //creating Player
  Future<Player> create(Player player) async {
    final db = await instance.database;
    
    final id = await db.insert(tablePlayers, player.toJson());
    return player.copy(id:id);
  }

  //read single player info
  Future<Player> readPlayerInfo(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tablePlayers,
      columns: PlayerFields.values,
      where: '${PlayerFields.id} = ?',
      whereArgs: [id],
    );

    if(maps.isNotEmpty){
      return Player.fromJson(maps.first);
    } else{
      //if db entry is not found
      throw Exception('ID $id not found');
    }
  }

  //read all player info
  Future<List<Player>> readAllPlayerInfo() async {
    final db = await instance.database;

    final result = await db.query(tablePlayers);

    return result.map((json) => Player.fromJson(json)).toList();
  }

  //update player info
  Future<int> update(Player player) async {
    final db = await instance.database;

    return db.update(
      tablePlayers,
      player.toJson(),
      where: '${PlayerFields.id} = ?',
      whereArgs: [player.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return db.delete(
      tablePlayers,
      where: '${PlayerFields.id} = ?',
      whereArgs: [id],
    );
  }

  //closing db
  Future close() async{
    final db = await instance.database;

    db.close();
  }
}
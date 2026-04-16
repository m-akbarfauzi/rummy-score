import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/error/exceptions.dart';
import '../models/game_session_model.dart';
import '../models/player_model.dart';
import '../models/round_score_model.dart';

abstract class GameLocalDataSource {
  Future<GameSessionModel> createGame(GameSessionModel game);
  Future<GameSessionModel?> getActiveGame();
  Future<List<GameSessionModel>> getGameHistory();
  Future<void> saveRoundScores(List<RoundScoreModel> scores);
  Future<void> updateGameSession(GameSessionModel game);
  Future<List<RoundScoreModel>> getRoundScores(String gameId);
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'rummy_score.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE games (
            id TEXT PRIMARY KEY,
            target_score INTEGER,
            is_finished INTEGER,
            is_kesalip_enabled INTEGER DEFAULT 0,
            created_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE players (
            id TEXT PRIMARY KEY,
            game_id TEXT,
            name TEXT,
            FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE round_scores (
            id TEXT PRIMARY KEY,
            game_id TEXT,
            round_number INTEGER,
            player_id TEXT,
            score INTEGER,
            FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
            FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE games ADD COLUMN is_kesalip_enabled INTEGER DEFAULT 0');
        }
      },
    );
  }

  @override
  Future<GameSessionModel> createGame(GameSessionModel game) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.insert('games', game.toDb());
        for (var player in game.players) {
          await txn.insert('players', (player as PlayerModel).toDb(game.id));
        }
      });
      return game;
    } catch (e) {
      throw LocalDatabaseException('Could not create game');
    }
  }

  @override
  Future<GameSessionModel?> getActiveGame() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'games',
        where: 'is_finished = ?',
        whereArgs: [0],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;

      final gameMap = maps.first;
      final String gameId = gameMap['id'];

      final List<Map<String, dynamic>> playerMaps = await db.query(
        'players',
        where: 'game_id = ?',
        whereArgs: [gameId],
      );

      final players = playerMaps.map((p) => PlayerModel.fromDb(p)).toList();
      return GameSessionModel.fromDb(gameMap, players);
    } catch (e) {
      throw LocalDatabaseException('Could not fetch active game');
    }
  }

  @override
  Future<List<GameSessionModel>> getGameHistory() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'games',
        where: 'is_finished = ?',
        whereArgs: [1],
        orderBy: 'created_at DESC',
      );

      List<GameSessionModel> games = [];
      for (var gameMap in maps) {
        final String gameId = gameMap['id'];
        final List<Map<String, dynamic>> playerMaps = await db.query(
          'players',
          where: 'game_id = ?',
          whereArgs: [gameId],
        );
        final players = playerMaps.map((p) => PlayerModel.fromDb(p)).toList();
        games.add(GameSessionModel.fromDb(gameMap, players));
      }
      return games;
    } catch (e) {
      throw LocalDatabaseException('Could not fetch history');
    }
  }

  @override
  Future<void> saveRoundScores(List<RoundScoreModel> scores) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        for (var score in scores) {
          await txn.insert('round_scores', score.toDb());
        }
      });
    } catch (e) {
      throw LocalDatabaseException('Could not save round scores');
    }
  }

  @override
  Future<void> updateGameSession(GameSessionModel game) async {
    try {
      final db = await database;
      await db.update(
        'games',
        game.toDb(),
        where: 'id = ?',
        whereArgs: [game.id],
      );
    } catch (e) {
      throw LocalDatabaseException('Could not update game');
    }
  }

  @override
  Future<List<RoundScoreModel>> getRoundScores(String gameId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'round_scores',
        where: 'game_id = ?',
        whereArgs: [gameId],
        orderBy: 'round_number ASC',
      );
      return maps.map((m) => RoundScoreModel.fromDb(m)).toList();
    } catch (e) {
      throw LocalDatabaseException('Could not fetch round scores');
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/round_score.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_local_data_source.dart';
import '../models/game_session_model.dart';
import '../models/player_model.dart';
import '../models/round_score_model.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalDataSource localDataSource;

  GameRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, GameSession>> createGame(GameSession game) async {
    try {
      final players = game.players
          .map((p) => PlayerModel(id: p.id, name: p.name))
          .toList();
      final gameModel = GameSessionModel(
        id: game.id,
        players: players,
        targetScore: game.targetScore,
        isFinished: game.isFinished,
        isKesalipEnabled: game.isKesalipEnabled,
        createdAt: game.createdAt,
      );
      final result = await localDataSource.createGame(gameModel);
      return Right(result);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure('Could not create game'));
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, GameSession?>> getActiveGame() async {
    try {
      final result = await localDataSource.getActiveGame();
      return Right(result);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure('Could not fetch active game'));
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<GameSession>>> getGameHistory() async {
    try {
      final result = await localDataSource.getGameHistory();
      return Right(result);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure('Could not fetch game history'));
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> saveRoundScores(List<RoundScore> scores) async {
    try {
      final scoreModels = scores
          .map((s) => RoundScoreModel(
                id: s.id,
                gameId: s.gameId,
                roundNumber: s.roundNumber,
                playerId: s.playerId,
                score: s.score,
              ))
          .toList();
      await localDataSource.saveRoundScores(scoreModels);
      return const Right(null);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure('Could not save round scores'));
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> updateGameSession(GameSession game) async {
    try {
      final players = game.players
          .map((p) => PlayerModel(id: p.id, name: p.name))
          .toList();
      final gameModel = GameSessionModel(
        id: game.id,
        players: players,
        targetScore: game.targetScore,
        isFinished: game.isFinished,
        isKesalipEnabled: game.isKesalipEnabled,
        createdAt: game.createdAt,
      );
      await localDataSource.updateGameSession(gameModel);
      return const Right(null);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure('Could not update game session'));
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<RoundScore>>> getRoundScores(String gameId) async {
    try {
      final result = await localDataSource.getRoundScores(gameId);
      return Right(result);
    } on LocalDatabaseException {
      return const Left(DatabaseFailure('Could not fetch round scores'));
    } catch (e) {
      return const Left(UnexpectedFailure('Unexpected error occurred'));
    }
  }
}

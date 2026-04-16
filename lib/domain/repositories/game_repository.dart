import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/game_session.dart';
import '../entities/round_score.dart';

abstract class GameRepository {
  Future<Either<Failure, GameSession>> createGame(GameSession game);
  Future<Either<Failure, GameSession?>> getActiveGame();
  Future<Either<Failure, List<GameSession>>> getGameHistory();
  Future<Either<Failure, void>> saveRoundScores(List<RoundScore> scores);
  Future<Either<Failure, void>> updateGameSession(GameSession game);
  Future<Either<Failure, List<RoundScore>>> getRoundScores(String gameId);
}

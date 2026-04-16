import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/round_score.dart';
import '../repositories/game_repository.dart';

class GetRoundScores implements UseCase<List<RoundScore>, GetRoundScoresParams> {
  final GameRepository repository;

  GetRoundScores(this.repository);

  @override
  Future<Either<Failure, List<RoundScore>>> call(GetRoundScoresParams params) async {
    return await repository.getRoundScores(params.gameId);
  }
}

class GetRoundScoresParams extends Equatable {
  final String gameId;

  const GetRoundScoresParams({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

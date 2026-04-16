import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/round_score.dart';
import '../repositories/game_repository.dart';

class SaveRoundScores implements UseCase<void, SaveRoundScoresParams> {
  final GameRepository repository;

  SaveRoundScores(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveRoundScoresParams params) async {
    return await repository.saveRoundScores(params.scores);
  }
}

class SaveRoundScoresParams extends Equatable {
  final List<RoundScore> scores;

  const SaveRoundScoresParams({required this.scores});

  @override
  List<Object> get props => [scores];
}

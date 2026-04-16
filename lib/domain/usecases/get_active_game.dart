import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/game_session.dart';
import '../repositories/game_repository.dart';

class GetActiveGame implements UseCase<GameSession?, NoParams> {
  final GameRepository repository;

  GetActiveGame(this.repository);

  @override
  Future<Either<Failure, GameSession?>> call(NoParams params) async {
    return await repository.getActiveGame();
  }
}

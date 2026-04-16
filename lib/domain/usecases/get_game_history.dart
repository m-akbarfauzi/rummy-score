import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/game_session.dart';
import '../repositories/game_repository.dart';

class GetGameHistory implements UseCase<List<GameSession>, NoParams> {
  final GameRepository repository;

  GetGameHistory(this.repository);

  @override
  Future<Either<Failure, List<GameSession>>> call(NoParams params) async {
    return await repository.getGameHistory();
  }
}

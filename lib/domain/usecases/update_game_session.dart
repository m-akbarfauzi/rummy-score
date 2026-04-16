import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/game_session.dart';
import '../repositories/game_repository.dart';

class UpdateGameSession implements UseCase<void, UpdateGameSessionParams> {
  final GameRepository repository;

  UpdateGameSession(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateGameSessionParams params) async {
    return await repository.updateGameSession(params.game);
  }
}

class UpdateGameSessionParams extends Equatable {
  final GameSession game;

  const UpdateGameSessionParams({required this.game});

  @override
  List<Object> get props => [game];
}

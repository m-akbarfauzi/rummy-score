import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/game_session.dart';
import '../repositories/game_repository.dart';

class CreateGame implements UseCase<GameSession, CreateGameParams> {
  final GameRepository repository;

  CreateGame(this.repository);

  @override
  Future<Either<Failure, GameSession>> call(CreateGameParams params) async {
    return await repository.createGame(params.game);
  }
}

class CreateGameParams extends Equatable {
  final GameSession game;

  const CreateGameParams({required this.game});

  @override
  List<Object> get props => [game];
}

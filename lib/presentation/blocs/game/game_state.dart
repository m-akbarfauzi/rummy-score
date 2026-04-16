import 'package:equatable/equatable.dart';
import '../../../domain/entities/game_session.dart';
import '../../../domain/entities/round_score.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameLoaded extends GameState {
  final GameSession game;
  final List<RoundScore> roundScores;
  final Map<String, int> totalScores;

  const GameLoaded({
    required this.game,
    required this.roundScores,
    required this.totalScores,
  });

  @override
  List<Object?> get props => [game, roundScores, totalScores];
}

class GameFinished extends GameState {
  final GameSession game;
  final List<RoundScore> roundScores;
  final Map<String, int> totalScores;
  final List<String> outPlayers;

  const GameFinished({
    required this.game,
    required this.roundScores,
    required this.totalScores,
    required this.outPlayers,
  });

  @override
  List<Object?> get props => [game, roundScores, totalScores, outPlayers];
}

class GameError extends GameState {
  final String message;
  const GameError(this.message);

  @override
  List<Object?> get props => [message];
}

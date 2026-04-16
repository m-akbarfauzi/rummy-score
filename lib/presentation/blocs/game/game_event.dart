import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class StartNewGameEvent extends GameEvent {
  final List<String> playerNames;
  final int targetScore;
  final bool isKesalipEnabled;

  const StartNewGameEvent(this.playerNames, this.targetScore, this.isKesalipEnabled);

  @override
  List<Object> get props => [playerNames, targetScore, isKesalipEnabled];
}

class AddRoundScoreEvent extends GameEvent {
  final Map<String, int> playerScores; // playerId -> score

  const AddRoundScoreEvent(this.playerScores);

  @override
  List<Object> get props => [playerScores];
}

class LoadActiveGameEvent extends GameEvent {}

class EndActiveGameEvent extends GameEvent {}

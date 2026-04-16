import 'package:equatable/equatable.dart';
import 'player.dart';

class GameSession extends Equatable {
  final String id;
  final List<Player> players;
  final int targetScore;
  final bool isFinished;
  final bool isKesalipEnabled;
  final DateTime createdAt;

  const GameSession({
    required this.id,
    required this.players,
    required this.targetScore,
    required this.isFinished,
    required this.isKesalipEnabled,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, players, targetScore, isFinished, isKesalipEnabled, createdAt];
}

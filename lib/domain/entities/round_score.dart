import 'package:equatable/equatable.dart';

class RoundScore extends Equatable {
  final String id;
  final String gameId;
  final int roundNumber;
  final String playerId;
  final int score;

  const RoundScore({
    required this.id,
    required this.gameId,
    required this.roundNumber,
    required this.playerId,
    required this.score,
  });

  @override
  List<Object> get props => [id, gameId, roundNumber, playerId, score];
}

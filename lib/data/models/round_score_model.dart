import '../../domain/entities/round_score.dart';

class RoundScoreModel extends RoundScore {
  const RoundScoreModel({
    required super.id,
    required super.gameId,
    required super.roundNumber,
    required super.playerId,
    required super.score,
  });

  factory RoundScoreModel.fromDb(Map<String, dynamic> json) {
    return RoundScoreModel(
      id: json['id'],
      gameId: json['game_id'],
      roundNumber: json['round_number'],
      playerId: json['player_id'],
      score: json['score'],
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'game_id': gameId,
      'round_number': roundNumber,
      'player_id': playerId,
      'score': score,
    };
  }
}

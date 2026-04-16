import '../../domain/entities/game_session.dart';
import 'player_model.dart';

class GameSessionModel extends GameSession {
  const GameSessionModel({
    required super.id,
    required super.players,
    required super.targetScore,
    required super.isFinished,
    required super.isKesalipEnabled,
    required super.createdAt,
  });

  factory GameSessionModel.fromDb(
      Map<String, dynamic> json, List<PlayerModel> players) {
    return GameSessionModel(
      id: json['id'],
      players: players,
      targetScore: json['target_score'],
      isFinished: json['is_finished'] == 1,
      isKesalipEnabled: json['is_kesalip_enabled'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'target_score': targetScore,
      'is_finished': isFinished ? 1 : 0,
      'is_kesalip_enabled': isKesalipEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

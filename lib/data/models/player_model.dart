import '../../domain/entities/player.dart';

class PlayerModel extends Player {
  const PlayerModel({required super.id, required super.name});

  factory PlayerModel.fromDb(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toDb(String gameId) {
    return {
      'id': id,
      'game_id': gameId,
      'name': name,
    };
  }
}

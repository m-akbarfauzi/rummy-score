import 'package:flutter/material.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/round_score.dart';
import '../../core/di/injection_container.dart' as di;
import '../../domain/usecases/get_round_scores.dart';

class HistoryDetailPage extends StatelessWidget {
  final GameSession game;

  const HistoryDetailPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Details')),
      body: FutureBuilder(
        future: di.sl<GetRoundScores>().call(GetRoundScoresParams(gameId: game.id)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load match details'));
          }
          
          final dartzResult = snapshot.data;
          if (dartzResult == null) return const SizedBox.shrink();
          
          return dartzResult.fold(
            (failure) => Center(child: Text(failure.message)),
            (scores) => _buildDetailView(context, scores),
          );
        },
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, List<RoundScore> scores) {
    final players = game.players;
    
    // total calculation
    Map<String, int> totals = {for (var p in players) p.id: 0};
    for (var s in scores) {
      if (totals.containsKey(s.playerId)) {
        totals[s.playerId] = totals[s.playerId]! + s.score;
      }
    }

    return Column(
      children: [
        // Header with Totals
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: players.map((p) {
              final total = totals[p.id] ?? 0;
              final isOut = total >= game.targetScore;
              return Column(
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: isOut ? TextDecoration.lineThrough : null,
                      color: isOut ? Colors.red : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    total.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isOut ? Colors.red : Colors.teal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        // Scores List
        Expanded(
          child: ListView.separated(
            itemCount: scores.isEmpty ? 0 : scores.last.roundNumber,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final roundNumber = index + 1;
              final scoresForRound = scores.where((rs) => rs.roundNumber == roundNumber).toList();
              
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text('R$roundNumber', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: players.map((p) {
                          final rScore = scoresForRound.firstWhere(
                              (rs) => rs.playerId == p.id,
                              orElse: () => throw Exception('Missing'));
                          return Text(rScore.score.toString(), style: const TextStyle(fontSize: 16));
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

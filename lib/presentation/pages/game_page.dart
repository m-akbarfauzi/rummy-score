import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import 'home_page.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  void _showAddRoundSheet(BuildContext context, GameLoaded currentState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return AddRoundSheet(
          players: currentState.game.players,
          onAdd: (Map<String, int> matchScores) {
            context.read<GameBloc>().add(AddRoundScoreEvent(matchScores));
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  void _showEndGameDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('End Game?'),
          content: const Text('Are you sure you want to end this game?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<GameBloc>().add(EndActiveGameEvent());
              },
              child: const Text('End Game'),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state is GameFinished) {
          final s = state;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Game Over!'),
              content: Text(
                s.outPlayers.isNotEmpty
                    ? 'Players OUT (reached ${s.game.targetScore}):\n${s.outPlayers.join(', ')}'
                    : 'The game has been manually ended.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                  child: const Text('Back to Home'),
                )
              ],
            ),
          );
        } else if (state is GameError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is GameLoading || state is GameInitial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is GameLoaded || state is GameFinished) {
          final game = state is GameLoaded ? state.game : (state as GameFinished).game;
          final totalScores = state is GameLoaded ? state.totalScores : (state as GameFinished).totalScores;
          final roundScores = state is GameLoaded ? state.roundScores : (state as GameFinished).roundScores;
          final players = game.players;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Scoreboard'),
              actions: [
                if (state is GameLoaded)
                  IconButton(
                    icon: const Icon(Icons.stop),
                    tooltip: 'End Game',
                    onPressed: _showEndGameDialog,
                  )
              ],
            ),
            body: Column(
              children: [
                // Header with Total scores
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: players.map((p) {
                      final total = totalScores[p.id] ?? 0;
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
                    itemCount: roundScores.isEmpty ? 0 : roundScores.last.roundNumber,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final roundNumber = index + 1;
                      final scoresForRound = roundScores.where((rs) => rs.roundNumber == roundNumber).toList();
                      
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
                                      orElse: () => throw Exception('Score missing'));
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
            ),
            floatingActionButton: state is GameLoaded
                ? FloatingActionButton.extended(
                    onPressed: () => _showAddRoundSheet(context, state),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Round'),
                  )
                : null,
          );
        }
        
        return const Scaffold();
      },
    );
  }
}

class AddRoundSheet extends StatefulWidget {
  final List players; // List<Player>
  final Function(Map<String, int>) onAdd;

  const AddRoundSheet({super.key, required this.players, required this.onAdd});

  @override
  State<AddRoundSheet> createState() => _AddRoundSheetState();
}

class _AddRoundSheetState extends State<AddRoundSheet> {
  final Map<String, int> _scores = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var p in widget.players) {
      _scores[p.id] = 0;
      _controllers[p.id] = TextEditingController(text: "0");
    }
  }
  
  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Add Round Scores', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...widget.players.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(child: Text(p.name, style: const TextStyle(fontSize: 16))),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _controllers[p.id],
                        keyboardType: const TextInputType.numberWithOptions(signed: true),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          if (int.tryParse(val) != null) {
                            _scores[p.id] = int.parse(val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              widget.onAdd(_scores);
            },
            child: const Text('SAVE ROUND', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

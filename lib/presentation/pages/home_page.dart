import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import 'config_page.dart';
import 'game_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(LoadActiveGameEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RummyScore'),
        centerTitle: true,
      ),
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is GameLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GameLoaded || state is GameFinished) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videogame_asset, size: 80, color: Colors.teal),
                  const SizedBox(height: 24),
                  const Text('Active game found!', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const GamePage()));
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume Game', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigPage()));
                    },
                    child: const Text('Start New Game Instead'),
                  ),
                  const SizedBox(height: 32),
                  _buildHistoryButton(context),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.style, size: 100, color: Colors.teal),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigPage()));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Game', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 16),
                _buildHistoryButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryButton(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
      },
      icon: const Icon(Icons.history),
      label: const Text('Match History', style: TextStyle(fontSize: 18)),
    );
  }
}

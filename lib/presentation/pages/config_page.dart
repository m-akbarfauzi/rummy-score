import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import 'game_page.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final _formKey = GlobalKey<FormState>();
  int _targetScore = 500;
  bool _isKesalipEnabled = false;
  final List<TextEditingController> _playerControllers = [
    TextEditingController(),
    TextEditingController()
  ];

  @override
  void dispose() {
    for (var controller in _playerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPlayer() {
    if (_playerControllers.length < 6) {
      setState(() {
        _playerControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 6 players allowed')),
      );
    }
  }

  void _removePlayer(int index) {
    if (_playerControllers.length > 2) {
      setState(() {
        _playerControllers[index].dispose();
        _playerControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Min 2 players required')),
      );
    }
  }

  void _startGame() {
    if (_formKey.currentState!.validate()) {
      final names = _playerControllers.map((c) => c.text.trim()).toList();
      context.read<GameBloc>().add(StartNewGameEvent(names, _targetScore, _isKesalipEnabled));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Setup')),
      body: BlocListener<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameLoaded) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GamePage()),
            );
          } else if (state is GameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Score',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _targetScore.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g 500',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (int.tryParse(value) == null) return 'Must be a number';
                          if (int.parse(value) <= 0) return 'Must be positive';
                          return null;
                        },
                        onChanged: (value) {
                          if (int.tryParse(value) != null) {
                            _targetScore = int.parse(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: const Text('Custom Rule: "Kesalip = 0"', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Players passed by another (who didn\'t start negative) reset to 0.'),
                  value: _isKesalipEnabled,
                  onChanged: (val) => setState(() => _isKesalipEnabled = val),
                  activeTrackColor: Colors.teal.withValues(alpha: 0.5),
                  activeThumbColor: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Players',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: _addPlayer,
                            icon: const Icon(Icons.person_add),
                            color: Colors.teal,
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(_playerControllers.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _playerControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'Player ${index + 1}',
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return 'Name required';
                                    return null;
                                  },
                                ),
                              ),
                              if (_playerControllers.length > 2)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                  onPressed: () => _removePlayer(index),
                                )
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: _startGame,
                child: const Text('START GAME', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

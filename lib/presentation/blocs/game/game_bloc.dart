import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/game_session.dart';
import '../../../domain/entities/player.dart';
import '../../../domain/entities/round_score.dart';
import '../../../domain/usecases/create_game.dart';
import '../../../domain/usecases/get_active_game.dart';
import '../../../domain/usecases/get_round_scores.dart';
import '../../../domain/usecases/save_round_scores.dart';
import '../../../domain/usecases/update_game_session.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final CreateGame createGame;
  final GetActiveGame getActiveGame;
  final GetRoundScores getRoundScores;
  final SaveRoundScores saveRoundScores;
  final UpdateGameSession updateGameSession;

  final _uuid = const Uuid();

  GameBloc({
    required this.createGame,
    required this.getActiveGame,
    required this.getRoundScores,
    required this.saveRoundScores,
    required this.updateGameSession,
  }) : super(GameInitial()) {
    on<LoadActiveGameEvent>(_onLoadActiveGame);
    on<StartNewGameEvent>(_onStartNewGame);
    on<AddRoundScoreEvent>(_onAddRoundScore);
    on<EndActiveGameEvent>(_onEndActiveGame);
  }

  Future<void> _onLoadActiveGame(
      LoadActiveGameEvent event, Emitter<GameState> emit) async {
    emit(GameLoading());
    final activeGameResult = await getActiveGame(NoParams());
    await activeGameResult.fold(
      (failure) async => emit(GameError(failure.message)),
      (game) async {
        if (game == null) {
          emit(GameInitial());
        } else {
          await _loadGameDetails(game, emit);
        }
      },
    );
  }

  Future<void> _loadGameDetails(
      GameSession game, Emitter<GameState> emit) async {
    final roundScoresResult = await getRoundScores(GetRoundScoresParams(gameId: game.id));
    roundScoresResult.fold(
        (failure) => emit(GameError(failure.message)),
        (scores) {
      final totalMap = _calculateTotalScores(game.players, scores);
      // check if game finished internally
      final outPlayers = game.players.where((p) => (totalMap[p.id] ?? 0) >= game.targetScore).toList();
      if (outPlayers.isNotEmpty || game.isFinished) {
        emit(GameFinished(
            game: game,
            roundScores: scores,
            totalScores: totalMap,
            outPlayers: outPlayers.map((e) => e.name).toList()));
      } else {
        emit(GameLoaded(
            game: game, roundScores: scores, totalScores: totalMap));
      }
    });
  }

  Future<void> _onStartNewGame(
      StartNewGameEvent event, Emitter<GameState> emit) async {
    emit(GameLoading());
    final activeGameCheck = await getActiveGame(NoParams());
    await activeGameCheck.fold(
      (f) {},
      (game) async {
        if (game != null) {
          final updated = GameSession(
              id: game.id,
              players: game.players,
              targetScore: game.targetScore,
              isFinished: true,
              isKesalipEnabled: game.isKesalipEnabled,
              createdAt: game.createdAt);
          await updateGameSession(UpdateGameSessionParams(game: updated));
        }
      },
    );

    final String gameId = _uuid.v4();
    final List<Player> players =
        event.playerNames.map((name) => Player(id: _uuid.v4(), name: name)).toList();
    final newGame = GameSession(
      id: gameId,
      players: players,
      targetScore: event.targetScore,
      isFinished: false,
      isKesalipEnabled: event.isKesalipEnabled,
      createdAt: DateTime.now(),
    );

    final createResult = await createGame(CreateGameParams(game: newGame));
    await createResult.fold(
      (failure) async => emit(GameError(failure.message)),
      (game) async => emit(GameLoaded(
          game: game, roundScores: const [], totalScores: _calculateTotalScores(players, []))),
    );
  }

  Future<void> _onAddRoundScore(
      AddRoundScoreEvent event, Emitter<GameState> emit) async {
    if (state is GameLoaded) {
      final currentState = state as GameLoaded;
      final int newRoundNumber = currentState.roundScores.isEmpty
          ? 1
          : (currentState.roundScores.last.roundNumber + 1);
      final oldTotalMap = _calculateTotalScores(currentState.game.players, currentState.roundScores);

      Map<String, int> preliminaryNewTotals = Map.from(oldTotalMap);
      for (var p in currentState.game.players) {
        preliminaryNewTotals[p.id] = (preliminaryNewTotals[p.id] ?? 0) + (event.playerScores[p.id] ?? 0);
      }

      final List<RoundScore> newScores = [];

      if (currentState.game.isKesalipEnabled) {
        final Set<String> kesalipPlayers = {};
        for (var p in currentState.game.players) {
          final oldTotal = oldTotalMap[p.id] ?? 0;
          final newTotal = preliminaryNewTotals[p.id] ?? 0;
          
          if (newTotal > oldTotal && oldTotal >= 0) {
            for (var otherP in currentState.game.players) {
              if (p.id == otherP.id) continue;
              final otherOldTotal = oldTotalMap[otherP.id] ?? 0;
              if (oldTotal < otherOldTotal && newTotal >= otherOldTotal) {
                kesalipPlayers.add(otherP.id);
              }
            }
          }
        }

        for (var p in currentState.game.players) {
          if (kesalipPlayers.contains(p.id)) {
            newScores.add(RoundScore(
                id: _uuid.v4(),
                gameId: currentState.game.id,
                roundNumber: newRoundNumber,
                playerId: p.id,
                score: -(oldTotalMap[p.id] ?? 0)));
          } else {
            newScores.add(RoundScore(
                id: _uuid.v4(),
                gameId: currentState.game.id,
                roundNumber: newRoundNumber,
                playerId: p.id,
                score: event.playerScores[p.id] ?? 0));
          }
        }
      } else {
        newScores.addAll(currentState.game.players.map((p) {
          return RoundScore(
              id: _uuid.v4(),
              gameId: currentState.game.id,
              roundNumber: newRoundNumber,
              playerId: p.id,
              score: event.playerScores[p.id] ?? 0);
        }));
      }

      final saveResult =
          await saveRoundScores(SaveRoundScoresParams(scores: newScores));
      await saveResult.fold(
        (failure) async => emit(GameError(failure.message)),
        (_) async {
          final updatedRoundScores = List<RoundScore>.from(currentState.roundScores)
            ..addAll(newScores);
          final updatedTotalMap =
              _calculateTotalScores(currentState.game.players, updatedRoundScores);

          final outPlayers = currentState.game.players
              .where((p) => (updatedTotalMap[p.id] ?? 0) >= currentState.game.targetScore)
              .toList();

          if (outPlayers.isNotEmpty) {
            final finishedGame = GameSession(
              id: currentState.game.id,
              players: currentState.game.players,
              targetScore: currentState.game.targetScore,
              isFinished: true,
              isKesalipEnabled: currentState.game.isKesalipEnabled,
              createdAt: currentState.game.createdAt,
            );
            await updateGameSession(UpdateGameSessionParams(game: finishedGame));
            emit(GameFinished(
              game: finishedGame,
              roundScores: updatedRoundScores,
              totalScores: updatedTotalMap,
              outPlayers: outPlayers.map((e) => e.name).toList(),
            ));
          } else {
            emit(GameLoaded(
              game: currentState.game,
              roundScores: updatedRoundScores,
              totalScores: updatedTotalMap,
            ));
          }
        },
      );
    }
  }

  Future<void> _onEndActiveGame(
      EndActiveGameEvent event, Emitter<GameState> emit) async {
    if (state is GameLoaded) {
      final currentState = state as GameLoaded;
      final finishedGame = GameSession(
        id: currentState.game.id,
        players: currentState.game.players,
        targetScore: currentState.game.targetScore,
        isFinished: true,
        isKesalipEnabled: currentState.game.isKesalipEnabled,
        createdAt: currentState.game.createdAt,
      );
      final updateResult = await updateGameSession(UpdateGameSessionParams(game: finishedGame));
      await updateResult.fold(
        (f) async => emit(GameError(f.message)),
        (_) async {
           emit(GameFinished(
             game: finishedGame,
             roundScores: currentState.roundScores,
             totalScores: currentState.totalScores,
             outPlayers: [],
           ));
        }
      );
    }
  }

  Map<String, int> _calculateTotalScores(
      List<Player> players, List<RoundScore> roundScores) {
    Map<String, int> totals = {};
    for (var p in players) {
      totals[p.id] = 0;
    }
    for (var score in roundScores) {
      if (totals.containsKey(score.playerId)) {
        totals[score.playerId] = totals[score.playerId]! + score.score;
      }
    }
    return totals;
  }
}

import 'package:get_it/get_it.dart';
import '../../data/datasources/game_local_data_source.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/usecases/create_game.dart';
import '../../domain/usecases/get_active_game.dart';
import '../../domain/usecases/get_game_history.dart';
import '../../domain/usecases/get_round_scores.dart';
import '../../domain/usecases/save_round_scores.dart';
import '../../domain/usecases/update_game_session.dart';

import '../../presentation/blocs/game/game_bloc.dart';
import '../../presentation/blocs/history/history_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Game

  // Bloc
  sl.registerFactory(() => GameBloc(
        createGame: sl(),
        getActiveGame: sl(),
        getRoundScores: sl(),
        saveRoundScores: sl(),
        updateGameSession: sl(),
      ));
  sl.registerFactory(() => HistoryBloc(getGameHistory: sl()));
  
  // Use cases
  sl.registerLazySingleton(() => CreateGame(sl()));
  sl.registerLazySingleton(() => GetActiveGame(sl()));
  sl.registerLazySingleton(() => GetGameHistory(sl()));
  sl.registerLazySingleton(() => GetRoundScores(sl()));
  sl.registerLazySingleton(() => SaveRoundScores(sl()));
  sl.registerLazySingleton(() => UpdateGameSession(sl()));
  
  // Repository
  sl.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(localDataSource: sl()),
  );
  
  // Data sources
  sl.registerLazySingleton<GameLocalDataSource>(
    () => GameLocalDataSourceImpl(),
  );
  
  // Core
  
  // External
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_game_history.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetGameHistory getGameHistory;

  HistoryBloc({required this.getGameHistory}) : super(HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
  }

  Future<void> _onLoadHistory(
      LoadHistoryEvent event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    final result = await getGameHistory(NoParams());
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (games) => emit(HistoryLoaded(games)),
    );
  }
}

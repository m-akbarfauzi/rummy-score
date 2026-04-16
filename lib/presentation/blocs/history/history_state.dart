import 'package:equatable/equatable.dart';
import '../../../domain/entities/game_session.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<GameSession> games;

  const HistoryLoaded(this.games);

  @override
  List<Object> get props => [games];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}

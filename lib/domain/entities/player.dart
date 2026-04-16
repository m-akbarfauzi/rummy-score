import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;

  const Player({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];
}

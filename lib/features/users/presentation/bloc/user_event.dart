import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class UsersLoadStarted extends UsersEvent {
  final String currentUserId;

  const UsersLoadStarted(this.currentUserId);

  @override
  List<Object?> get props => [currentUserId];
}

class UsersUpdated extends UsersEvent {
  final List<dynamic> users;

  const UsersUpdated(this.users);

  @override
  List<Object?> get props => [users];
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/user_list_entity.dart';

enum UsersStatus { initial, loading, loaded, error }

class UsersState extends Equatable {
  final UsersStatus status;
  final List<UserListEntity> users;
  final String? errorMessage;

  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.errorMessage,
  });

  UsersState copyWith({
    UsersStatus? status,
    List<UserListEntity>? users,
    String? errorMessage,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, errorMessage];
}

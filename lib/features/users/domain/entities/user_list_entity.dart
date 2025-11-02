import 'package:equatable/equatable.dart';

class UserListEntity extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isOnline;

  const UserListEntity({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [id, displayName, email, photoUrl, isOnline];
}

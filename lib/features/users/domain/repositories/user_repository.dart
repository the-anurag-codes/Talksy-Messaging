import 'package:dartz/dartz.dart';
import '../entities/user_list_entity.dart';
import '../../../../core/errors/failure.dart';

abstract class UsersRepository {
  Stream<Either<Failure, List<UserListEntity>>> getAllUsers(
    String currentUserId,
  );
  Future<Either<Failure, void>> updateUserStatus(String userId, bool isOnline);
}

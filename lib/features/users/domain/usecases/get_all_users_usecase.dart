import 'package:dartz/dartz.dart';
import '../entities/user_list_entity.dart';
import '../repositories/user_repository.dart';
import '../../../../core/errors/failure.dart';

class GetAllUsersUseCase {
  final UsersRepository repository;

  GetAllUsersUseCase(this.repository);

  Stream<Either<Failure, List<UserListEntity>>> call(String currentUserId) {
    return repository.getAllUsers(currentUserId);
  }
}

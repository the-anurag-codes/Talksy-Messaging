import 'package:dartz/dartz.dart';
import '../../domain/entities/user_list_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, List<UserListEntity>>> getAllUsers(
    String currentUserId,
  ) {
    try {
      return remoteDataSource
          .getAllUsers(currentUserId)
          .map((users) => Right<Failure, List<UserListEntity>>(users))
          .handleError((error) {
            return Left<Failure, List<UserListEntity>>(
              ServerFailure(error.toString()),
            );
          });
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserStatus(
    String userId,
    bool isOnline,
  ) async {
    try {
      await remoteDataSource.updateUserStatus(userId, isOnline);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

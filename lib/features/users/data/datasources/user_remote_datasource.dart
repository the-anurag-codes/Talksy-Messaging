import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_list_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class UsersRemoteDataSource {
  Stream<List<UserListModel>> getAllUsers(String currentUserId);
  Future<void> updateUserStatus(String userId, bool isOnline);
  Future<void> createUserDocument(
    String userId,
    String displayName,
    String email,
  );
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final FirebaseFirestore firestore;

  UsersRemoteDataSourceImpl(this.firestore);

  @override
  Stream<List<UserListModel>> getAllUsers(String currentUserId) {
    try {
      return firestore
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => UserListModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw ServerException('Failed to get users: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserStatus(String userId, bool isOnline) async {
    try {
      await firestore.collection('users').doc(userId).set({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to update status: ${e.toString()}');
    }
  }

  @override
  Future<void> createUserDocument(
    String userId,
    String displayName,
    String email,
  ) async {
    try {
      await firestore.collection('users').doc(userId).set({
        'displayName': displayName,
        'email': email,
        'isOnline': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to create user: ${e.toString()}');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_list_entity.dart';

class UserListModel extends UserListEntity {
  const UserListModel({
    required super.id,
    required super.displayName,
    required super.email,
    super.photoUrl,
    super.isOnline,
  });

  factory UserListModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserListModel(
      id: doc.id,
      displayName: data['displayName'] ?? 'Unknown User',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      isOnline: data['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    };
  }
}

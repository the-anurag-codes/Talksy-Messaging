import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class ChatRemoteDataSource {
  Future<void> sendMessage(MessageModel message);

  Stream<List<MessageModel>> getMessagesStream({
    required String userId,
    required String otherUserId,
  });

  Future<void> sendTypingIndicator({
    required String userId,
    required String otherUserId,
    required bool isTyping,
  });

  Stream<bool> getTypingStream({
    required String userId,
    required String otherUserId,
  });

  Future<void> markMessageAsRead(String messageId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> sendMessage(MessageModel message) async {
    try {
      final chatId = MessageModel.getChatId(
        message.senderId,
        message.receiverId,
      );

      // Add message to chat collection
      await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toFirestore());

      // Update chat metadata (last message, timestamp)
      await firestore.collection('chats').doc(chatId).set({
        'participants': [message.senderId, message.receiverId],
        'lastMessage': message.content,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to send message: ${e.toString()}');
    }
  }

  @override
  Stream<List<MessageModel>> getMessagesStream({
    required String userId,
    required String otherUserId,
  }) {
    try {
      final chatId = MessageModel.getChatId(userId, otherUserId);

      return firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => MessageModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw ServerException('Failed to get messages: ${e.toString()}');
    }
  }

  @override
  Future<void> sendTypingIndicator({
    required String userId,
    required String otherUserId,
    required bool isTyping,
  }) async {
    try {
      final chatId = MessageModel.getChatId(userId, otherUserId);

      await firestore
          .collection('chats')
          .doc(chatId)
          .collection('typing')
          .doc(userId)
          .set({
            'isTyping': isTyping,
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Auto-delete after 3 seconds if still typing
      if (isTyping) {
        Future.delayed(const Duration(seconds: 3), () {
          firestore
              .collection('chats')
              .doc(chatId)
              .collection('typing')
              .doc(userId)
              .delete();
        });
      }
    } catch (e) {
      print('Failed to send typing indicator: $e');
    }
  }

  @override
  Stream<bool> getTypingStream({
    required String userId,
    required String otherUserId,
  }) {
    try {
      final chatId = MessageModel.getChatId(userId, otherUserId);

      return firestore
          .collection('chats')
          .doc(chatId)
          .collection('typing')
          .doc(otherUserId)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) return false;

            final data = snapshot.data();
            if (data == null) return false;

            return data['isTyping'] as bool? ?? false;
          });
    } catch (e) {
      return Stream.value(false);
    }
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    try {
      // Implementation for read receipts
      // You can update the message status here
    } catch (e) {
      print('Failed to mark message as read: $e');
    }
  }
}

import 'package:dartz/dartz.dart';
import '../entities/message_entity.dart';
import '../../../../core/errors/failure.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> connect(String userId);

  Future<Either<Failure, void>> disconnect();

  Future<Either<Failure, void>> sendMessage(MessageEntity message);

  Stream<MessageEntity> get messageStream;

  Stream<bool> get typingStream;

  Future<Either<Failure, void>> sendTypingIndicator({
    required String senderId,
    required String receiverId,
    required bool isTyping,
  });
}

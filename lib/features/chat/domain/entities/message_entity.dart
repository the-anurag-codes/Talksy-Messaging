import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, delivered, read, failed }

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    senderName,
    receiverId,
    content,
    timestamp,
    status,
  ];
}

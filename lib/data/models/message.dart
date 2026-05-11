import 'package:equatable/equatable.dart';

enum MessageSender { user, agency }

class Message extends Equatable {
  final String id;
  final String conversationId;
  final MessageSender sender;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  const Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, conversationId, sender, text, createdAt, isRead];
}

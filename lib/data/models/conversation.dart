import 'package:equatable/equatable.dart';

import 'message.dart';

class Conversation extends Equatable {
  final String id;
  final String agencyId;
  final String? bookingId;
  final String agencyName;
  final String? agencyAvatarUrl;
  final List<Message> messages;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.agencyId,
    this.bookingId,
    required this.agencyName,
    this.agencyAvatarUrl,
    required this.messages,
    required this.updatedAt,
  });

  int get unreadCount => messages
      .where((m) => m.sender == MessageSender.agency && !m.isRead)
      .length;

  Message? get lastMessage =>
      messages.isNotEmpty ? messages.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b) : null;

  Conversation copyWith({
    String? id,
    String? agencyId,
    String? bookingId,
    String? agencyName,
    String? agencyAvatarUrl,
    List<Message>? messages,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      bookingId: bookingId ?? this.bookingId,
      agencyName: agencyName ?? this.agencyName,
      agencyAvatarUrl: agencyAvatarUrl ?? this.agencyAvatarUrl,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, agencyId, bookingId, agencyName, agencyAvatarUrl, messages, updatedAt];
}

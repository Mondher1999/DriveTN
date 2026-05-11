import 'package:equatable/equatable.dart';

import '../../../data/models/conversation.dart';

class MessagesState extends Equatable {
  final List<Conversation> conversations;
  final String? selectedConversationId;
  final bool isLoading;

  const MessagesState({
    this.conversations = const [],
    this.selectedConversationId,
    this.isLoading = false,
  });

  MessagesState copyWith({
    List<Conversation>? conversations,
    String? selectedConversationId,
    bool? isLoading,
    bool clearSelectedConversationId = false,
  }) {
    return MessagesState(
      conversations: conversations ?? this.conversations,
      selectedConversationId: clearSelectedConversationId
          ? null
          : (selectedConversationId ?? this.selectedConversationId),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [conversations, selectedConversationId, isLoading];
}

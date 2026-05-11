import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/message.dart';
import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit() : super(const MessagesState(isLoading: true)) {
    loadConversations();
  }

  Future<void> loadConversations() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 300));
    final convs = List.of(MockData.conversations)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    emit(state.copyWith(conversations: convs, isLoading: false));
  }

  void selectConversation(String? id) {
    emit(state.copyWith(selectedConversationId: id));
  }

  void markAsRead(String conversationId) {
    final updated = state.conversations.map((c) {
      if (c.id != conversationId) return c;
      final newMessages = c.messages.map((m) {
        if (m.sender == MessageSender.agency && !m.isRead) {
          return Message(
            id: m.id,
            conversationId: m.conversationId,
            sender: m.sender,
            text: m.text,
            createdAt: m.createdAt,
            isRead: true,
          );
        }
        return m;
      }).toList();
      return c.copyWith(messages: newMessages);
    }).toList();
    emit(state.copyWith(conversations: updated));
  }

  void sendMessage(String conversationId, String text) {
    final now = DateTime.now();
    final newMessage = Message(
      id: 'm-${now.millisecondsSinceEpoch}',
      conversationId: conversationId,
      sender: MessageSender.user,
      text: text,
      createdAt: now,
      isRead: true,
    );

    final updated = state.conversations.map((c) {
      if (c.id != conversationId) return c;
      return c.copyWith(
        messages: [...c.messages, newMessage],
        updatedAt: now,
      );
    }).toList();

    emit(state.copyWith(conversations: updated));
  }
}

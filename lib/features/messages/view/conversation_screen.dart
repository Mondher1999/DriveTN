import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/models/message.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/messages_cubit.dart';
import '../bloc/messages_state.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;
  const ConversationScreen({super.key, required this.conversationId});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<MessagesCubit>().sendMessage(widget.conversationId, text);
    _inputController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<MessagesCubit, MessagesState>(
        builder: (context, state) {
          final conv = state.conversations.firstWhere(
            (c) => c.id == widget.conversationId,
          );

          return SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          LucideIcons.chevronLeft,
                          color: AppColors.ink,
                        ),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.softWarm,
                        backgroundImage: conv.agencyAvatarUrl != null
                            ? NetworkImage(conv.agencyAvatarUrl!)
                            : null,
                        child: conv.agencyAvatarUrl == null
                            ? Text(
                                conv.agencyName.substring(0, 1),
                                style: AppTypography.body(
                                  size: 14,
                                  weight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conv.agencyName,
                              style: AppTypography.body(
                                size: 15,
                                weight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Agence de location',
                              style: AppTypography.body(
                                size: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: conv.messages.length,
                    itemBuilder: (context, index) {
                      final msg = conv.messages[index];
                      final prev = index > 0 ? conv.messages[index - 1] : null;
                      final showDate = _shouldShowDate(prev, msg);
                      return Column(
                        children: [
                          if (showDate) _DateSeparator(date: msg.createdAt),
                          _MessageBubble(message: msg),
                        ],
                      );
                    },
                  ),
                ),
                // Input
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _inputController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: InputDecoration(
                              hintText: 'Écrire un message...',
                              hintStyle: AppTypography.body(
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _send,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.gradientStart,
                                AppColors.gradientEnd,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.send,
                            size: 18,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _shouldShowDate(Message? prev, Message current) {
    if (prev == null) return true;
    final p = DateTime(prev.createdAt.year, prev.createdAt.month, prev.createdAt.day);
    final c = DateTime(current.createdAt.year, current.createdAt.month, current.createdAt.day);
    return p != c;
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    String label;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) {
      label = 'Aujourd\'hui';
    } else if (d == today.subtract(const Duration(days: 1))) {
      label = 'Hier';
    } else {
      label = DateFormat('EEEE d MMMM', 'fr_FR').format(date);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTypography.caps(
              size: 10,
              letterSpacing: 1,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender == MessageSender.user;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                )
              : null,
          color: isMe ? null : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe
              ? null
              : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w500,
                color: isMe ? AppColors.surface : AppColors.ink,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.createdAt),
                  style: AppTypography.body(
                    size: 10,
                    weight: FontWeight.w500,
                    color: isMe
                        ? AppColors.surface.withValues(alpha: 0.75)
                        : AppColors.textMuted,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.checkCheck,
                    size: 12,
                    color: AppColors.surface.withValues(alpha: 0.75),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

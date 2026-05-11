import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/models/conversation.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/messages_cubit.dart';
import '../bloc/messages_state.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<MessagesCubit, MessagesState>(
          builder: (context, state) {
            final filtered = state.conversations.where((c) {
              if (_query.isEmpty) return true;
              return c.agencyName.toLowerCase().contains(_query.toLowerCase());
            }).toList();

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '— MESSAGERIE',
                          style: AppTypography.caps(
                            size: 10,
                            letterSpacing: 2.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filtered.length} conversation${filtered.length > 1 ? 's' : ''}',
                          style: AppTypography.h1(
                            size: 28,
                            weight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Search
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une conversation...',
                          hintStyle: AppTypography.body(
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          prefixIcon: const Icon(
                            LucideIcons.search,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                  child: const Icon(
                                    LucideIcons.x,
                                    size: 18,
                                    color: AppColors.textMuted,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Liste
                if (state.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.ink),
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.messageSquare,
                            size: 48,
                            color: AppColors.textMuted.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune conversation',
                            style: AppTypography.body(
                              size: 15,
                              weight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final conv = filtered[index];
                          return _ConversationTile(
                            conversation: conv,
                            onTap: () {
                              context
                                  .read<MessagesCubit>()
                                  .markAsRead(conv.id);
                              context.push('/conversation/${conv.id}');
                            },
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inDays < 1) return DateFormat('HH:mm').format(dt);
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return DateFormat('EEE', 'fr_FR').format(dt);
    return DateFormat('d MMM', 'fr_FR').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final last = conversation.lastMessage;
    final unread = conversation.unreadCount;
    final isUnread = unread > 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.softWarm,
                  backgroundImage: conversation.agencyAvatarUrl != null
                      ? NetworkImage(conversation.agencyAvatarUrl!)
                      : null,
                  child: conversation.agencyAvatarUrl == null
                      ? Text(
                          conversation.agencyName.substring(0, 1),
                          style: AppTypography.h2(
                            size: 18,
                            weight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        )
                      : null,
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.agencyName,
                          style: AppTypography.body(
                            size: 15,
                            weight: isUnread ? FontWeight.w800 : FontWeight.w700,
                            color: AppColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        last != null ? _timeAgo(last.createdAt) : '',
                        style: AppTypography.body(
                          size: 11,
                          weight: FontWeight.w500,
                          color: isUnread ? AppColors.accent : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          last?.text ?? '',
                          style: AppTypography.body(
                            size: 13,
                            weight: isUnread ? FontWeight.w600 : FontWeight.w500,
                            color: isUnread
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$unread',
                            style: AppTypography.body(
                              size: 11,
                              weight: FontWeight.w800,
                              color: AppColors.surface,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:safe_space_app/models/conversation.dart';
import 'package:safe_space_app/utils/constants/app_colors.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEEE').format(timestamp);
    return DateFormat('MMM d').format(timestamp);
  }

  String _getMessagePreview() {
    if (conversation.lastMessage == null) return 'No messages yet';
    
    final message = conversation.lastMessage!;
    if (message.hasAttachment) {
      if (message.isImage) return '📷 Photo';
      return '📎 Attachment';
    }
    
    return message.content.length > 50 
        ? '${message.content.substring(0, 50)}...'
        : message.content;
  }

  @override
  Widget build(BuildContext context) {
    final profile = conversation.otherUserProfile;
    final hasUnread = conversation.unreadCount > 0;
    
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        backgroundImage: profile?.avatarUrl != null 
            ? CachedNetworkImageProvider(profile!.avatarUrl!)
            : null,
        child: profile?.avatarUrl == null
            ? Text(
                (profile?.displayName ?? '?').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              profile?.displayName ?? 'Unknown User',
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        _getMessagePreview(),
        style: TextStyle(
          color: hasUnread ? Colors.black87 : Colors.grey[600],
          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTimestamp(conversation.lastMessageTime),
        style: TextStyle(
          color: hasUnread ? AppColors.primary : Colors.grey[500],
          fontSize: 12,
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}

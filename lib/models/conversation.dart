import 'package:safe_space_app/models/message.dart';
import 'package:safe_space_app/models/user_profile.dart';

class Conversation {
  final String otherUserId;
  final UserProfile? otherUserProfile;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime? lastMessageTime;

  const Conversation({
    required this.otherUserId,
    this.otherUserProfile,
    this.lastMessage,
    required this.unreadCount,
    this.lastMessageTime,
  });

  Conversation copyWith({
    String? otherUserId,
    UserProfile? otherUserProfile,
    Message? lastMessage,
    int? unreadCount,
    DateTime? lastMessageTime,
  }) {
    return Conversation(
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserProfile: otherUserProfile ?? this.otherUserProfile,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }
}

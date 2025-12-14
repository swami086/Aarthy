import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types show User, Message, TextMessage, ImageMessage, FileMessage, PartialText;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'package:safe_space_app/models/user_profile.dart';
import 'package:safe_space_app/utils/constants/app_colors.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final UserProfile? otherUserProfile;

  const ChatDetailScreen({
    super.key,
    required this.otherUserId,
    this.otherUserProfile,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  bool _isUploading = false;
  UserProfile? _resolvedOtherProfile;

  @override
  void initState() {
    super.initState();
    // Mark messages as read when opening chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = ref.read(chatServiceProvider);
      service.markMessagesAsRead(widget.otherUserId);
    });
  }

  types.User _mapUserToFlutterUser(UserProfile? profile, String userId) {
    return types.User(
      id: userId,
      firstName: profile?.displayName ?? 'User',
      imageUrl: profile?.avatarUrl,
    );
  }

  types.Message _mapMessageToFlutterMessage(
    message,
    String currentUserId,
    UserProfile? otherProfile,
  ) {
    final author = _mapUserToFlutterUser(
      message.senderId == currentUserId ? null : otherProfile,
      message.senderId,
    );

    final metadata = <String, dynamic>{};
    if (message.senderId == currentUserId) {
      metadata['isRead'] = message.isRead;
    }

    if (message.hasAttachment) {
      if (message.isImage) {
        return types.ImageMessage(
          id: message.id,
          author: author,
          createdAt: message.createdAt.millisecondsSinceEpoch,
          uri: message.attachmentUrl!,
          name: 'image',
          size: 0,
          metadata: metadata,
        );
      } else {
        return types.FileMessage(
          id: message.id,
          author: author,
          createdAt: message.createdAt.millisecondsSinceEpoch,
          uri: message.attachmentUrl!,
          name: message.content.isNotEmpty ? message.content : 'file',
          size: 0,
          metadata: metadata,
        );
      }
    }

    return types.TextMessage(
      id: message.id,
      author: author,
      createdAt: message.createdAt.millisecondsSinceEpoch,
      text: message.content,
      metadata: metadata,
    );
  }

  Widget _imageMessageWithReceipts(
    types.ImageMessage message, {
    required int messageWidth,
  }) {
    final isRead = message.metadata?['isRead'];
    final imageWidget = ImageMessage(
      message: message,
      messageWidth: messageWidth,
    );

    if (isRead != null) {
      return Stack(
        children: [
          imageWidget,
          Positioned(
            bottom: 4,
            right: 4,
            child: _buildReadReceipt(isRead),
          ),
        ],
      );
    }
    return imageWidget;
  }

  Widget _fileMessageWithReceipts(
    types.FileMessage message, {
    required int messageWidth,
  }) {
    final isRead = message.metadata?['isRead'];
    final fileWidget = FileMessage(
      message: message,
    );

    if (isRead != null) {
      return Stack(
        children: [
          fileWidget,
          Positioned(
            bottom: 4,
            right: 4,
            child: _buildReadReceipt(isRead),
          ),
        ],
      );
    }
    return fileWidget;
  }

  Widget _textMessageWithReceipts(
    types.TextMessage message, {
    required int messageWidth,
    required bool showName,
  }) {
    final isRead = message.metadata?['isRead'];
    final textWidget = TextMessage(
      emojiEnlargementBehavior: EmojiEnlargementBehavior.multi,
      hideBackgroundOnEmojiMessages: false,
      message: message,
      showName: showName,
      usePreviewData: true,
    );

    if (isRead != null) {
      return Stack(
        children: [
          textWidget,
          Positioned(
            bottom: 4,
            right: 4,
            child: _buildReadReceipt(isRead),
          ),
        ],
      );
    }
    return textWidget;
  }

  Widget _buildReadReceipt(bool isRead) {
    if (!isRead) {
      return const Icon(Icons.done, size: 12, color: Colors.grey);
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done_all, size: 12, color: Colors.blue[400]),
        ],
      );
    }
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final service = ref.read(chatServiceProvider);
    try {
      await service.sendMessage(widget.otherUserId, message.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Future<void> _handleAttachmentPressed() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Photo'),
              onTap: () {
                Navigator.pop(context);
                _handleImageSelection();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                _handleFileSelection();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImageSelection() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    
    if (result != null) {
      await _uploadAndSendAttachment(File(result.path), 'image');
    }
  }

  Future<void> _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles();
    
    if (result != null && result.files.single.path != null) {
      await _uploadAndSendAttachment(
        File(result.files.single.path!),
        'file',
      );
    }
  }

  Future<void> _uploadAndSendAttachment(File file, String type) async {
    setState(() => _isUploading = true);
    
    try {
      final service = ref.read(chatServiceProvider);
      final messageId = const Uuid().v4();
      
      final url = await service.uploadAttachment(file, messageId);
      await service.sendMessage(
        widget.otherUserId,
        '',
        attachmentUrl: url,
        attachmentType: type,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(conversationMessagesProvider(widget.otherUserId));
    final currentUser = ref.watch(currentUserProvider);
    final otherUserProfile = widget.otherUserProfile ?? 
        ref.watch(userProfileProvider(widget.otherUserId)).value;
    
    // Update resolved profile
    _resolvedOtherProfile = otherUserProfile;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final flutterUser = _mapUserToFlutterUser(null, currentUser.id);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (otherUserProfile?.avatarUrl != null)
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(otherUserProfile!.avatarUrl!),
              ),
            if (otherUserProfile?.avatarUrl == null)
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  (otherUserProfile?.displayName ?? '?').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                otherUserProfile?.displayName ?? 'Chat',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: messagesAsync.when(
        data: (messages) {
          // Mark new unread messages as read
          final hasUnreadIncoming = messages.any((m) => 
            m.receiverId == currentUser.id && !m.isRead
          );
          if (hasUnreadIncoming) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(chatServiceProvider).markMessagesAsRead(widget.otherUserId);
            });
          }

          final flutterMessages = messages
              .map((m) => _mapMessageToFlutterMessage(m, currentUser.id, _resolvedOtherProfile))
              .toList()
              .reversed
              .toList();

          return Stack(
            children: [
              Chat(
                messages: flutterMessages,
                onSendPressed: _handleSendPressed,
                onAttachmentPressed: _handleAttachmentPressed,
                user: flutterUser,
                textMessageBuilder: _textMessageWithReceipts,
                imageMessageBuilder: _imageMessageWithReceipts,
                fileMessageBuilder: _fileMessageWithReceipts,
                theme: DefaultChatTheme(
                  primaryColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  inputBackgroundColor: Colors.grey[100]!,
                  sendButtonIcon: const Icon(Icons.send, color: AppColors.primary),
                ),
              ),
              if (_isUploading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading messages: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(conversationMessagesProvider(widget.otherUserId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

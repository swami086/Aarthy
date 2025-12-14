
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final String? attachmentUrl;
  final String? attachmentType;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    this.attachmentUrl,
    this.attachmentType,
    required this.createdAt,
  });

  bool get isImage => attachmentType == 'image';
  bool get hasAttachment => attachmentUrl != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'is_read': isRead,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool,
      attachmentUrl: json['attachment_url'] as String?,
      attachmentType: json['attachment_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    bool? isRead,
    String? attachmentUrl,
    String? attachmentType,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

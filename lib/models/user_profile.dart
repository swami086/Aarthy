enum UserRole { mentor, mentee }

class UserProfile {
  final String userId;
  final UserRole role;
  final String? bio;
  final String? avatarUrl;
  final List<String> expertiseAreas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.userId,
    required this.role,
    this.bio,
    this.avatarUrl,
    this.expertiseAreas = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.mentee,
      ),
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      expertiseAreas: (json['expertise_areas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role.name,
      'bio': bio,
      'avatar_url': avatarUrl,
      'expertise_areas': expertiseAreas,
    };
  }

  UserProfile copyWith({
    String? userId,
    UserRole? role,
    String? bio,
    String? avatarUrl,
    List<String>? expertiseAreas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      expertiseAreas: expertiseAreas ?? this.expertiseAreas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName => (bio != null && bio!.isNotEmpty) ? bio!.split('\n').first : 'Anonymous';

  bool hasExpertise(String focusAreaId) {
    return expertiseAreas.contains(focusAreaId);
  }
}

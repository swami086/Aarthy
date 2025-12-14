class Review {
  final String id;
  final String mentorId;
  final String menteeId;
  final String? appointmentId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final bool isFlagged;

  Review({
    required this.id,
    required this.mentorId,
    required this.menteeId,
    this.appointmentId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.isFlagged = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      mentorId: json['mentor_id'] as String,
      menteeId: json['mentee_id'] as String,
      appointmentId: json['appointment_id'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isFlagged: json['is_flagged'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mentor_id': mentorId,
      'mentee_id': menteeId,
      'appointment_id': appointmentId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'is_flagged': isFlagged,
    };
  }

  Review copyWith({
    String? id,
    String? mentorId,
    String? menteeId,
    String? appointmentId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    bool? isFlagged,
  }) {
    return Review(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      menteeId: menteeId ?? this.menteeId,
      appointmentId: appointmentId ?? this.appointmentId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      isFlagged: isFlagged ?? this.isFlagged,
    );
  }

  static double getAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold(0.0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }
}

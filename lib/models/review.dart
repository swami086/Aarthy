class Review {
  final String id;
  final String mentorId;
  final String menteeId;
  final String? appointmentId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.mentorId,
    required this.menteeId,
    this.appointmentId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      mentorId: json['mentor_id'] as String,
      menteeId: json['mentee_id'] as String,
      appointmentId: json['appointment_id'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
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
    };
  }

  static double getAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold(0.0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  String get _formattedDate {
    // Simple logic for "2 weeks ago" style, simplified for now
    final diff = DateTime.now().difference(review.createdAt);
    if (diff.inDays > 30) {
       return DateFormat.yMMMd().format(review.createdAt);
    } else if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else {
      return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.indigo,
                child: Text('A', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anonymous Mentee',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                size: 14,
                color: Colors.amber,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment ?? '',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
             style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:the_elsewheres/domain/firebase/model/feedback_model.dart';
class EventFeedbacksDialog extends StatelessWidget {
  final List<FeedBackModel> feedbacks;
  final String eventName;

  const EventFeedbacksDialog({
    Key? key,
    required this.feedbacks,
    required this.eventName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    // Calculate average rating
    double averageRating = 0.0;
    if (feedbacks.isNotEmpty) {
      double totalRating = feedbacks.fold(0.0, (sum, feedback) => sum + feedback.rating);
      averageRating = totalRating / feedbacks.length;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.8,
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.reviews,
                        color: colorScheme.onPrimary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Event Feedbacks',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              eventName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          Icons.rate_review,
                          '${feedbacks.length}',
                          'Reviews',
                          colorScheme.onPrimary,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: colorScheme.onPrimary.withOpacity(0.3),
                        ),
                        _buildStatItem(
                          context,
                          Icons.star,
                          averageRating.toStringAsFixed(1),
                          'Average',
                          colorScheme.onPrimary,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: colorScheme.onPrimary.withOpacity(0.3),
                        ),
                        _buildRatingDistribution(context, colorScheme.onPrimary),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Feedbacks List
            Expanded(
              child: feedbacks.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: feedbacks.length,
                itemBuilder: (context, index) {
                  return _buildFeedbackCard(context, feedbacks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingDistribution(BuildContext context, Color color) {
    // Calculate rating distribution
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var feedback in feedbacks) {
      int roundedRating = feedback.rating.round();
      if (roundedRating >= 1 && roundedRating <= 5) {
        distribution[roundedRating] = distribution[roundedRating]! + 1;
      }
    }

    return Column(
      children: [
        Icon(Icons.bar_chart, color: color, size: 24),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 3, 4, 5].map((rating) {
            int count = distribution[rating] ?? 0;
            double height = feedbacks.isNotEmpty ? (count / feedbacks.length) * 20 + 2 : 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 4,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Text(
          'Distribution',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_neutral,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Feedbacks Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your thoughts\nabout this event!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, FeedBackModel feedback) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info and Rating
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Text(
                  (feedback.login?.isNotEmpty == true)
                      ? feedback.login!.substring(0, 1).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.login ?? 'Anonymous User',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (feedback.createdAt != null)
                      Text(
                        _formatDate(feedback.createdAt!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),

              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRatingColor(feedback.rating).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getRatingColor(feedback.rating).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: _getRatingColor(feedback.rating),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      feedback.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getRatingColor(feedback.rating),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Stars Display
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 20,
                color: index < feedback.rating.round()
                    ? Colors.amber
                    : colorScheme.onSurfaceVariant.withOpacity(0.3),
              );
            }),
          ),
          // Comment
          if (feedback.comment?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                feedback.comment!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

// Usage example for your button:
void _showFeedbacksDialog(BuildContext context, List<FeedBackModel> feedbacks, String eventName) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return EventFeedbacksDialog(
        feedbacks: feedbacks,
        eventName: eventName,
      );
    },
  );
}

// Update your button to use this:
/*
Expanded(
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.pop(context);
      _showFeedbacksDialog(context, feedbacksList, event.eventName);
    },
    icon: const Icon(Icons.reviews, size: 18),
    label: const Text('View Feedbacks'),
    style: OutlinedButton.styleFrom(
      foregroundColor: colorScheme.primary,
      side: BorderSide(color: colorScheme.primary),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),
*/
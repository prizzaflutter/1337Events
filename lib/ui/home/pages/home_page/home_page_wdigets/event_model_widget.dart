import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/ui/view_models/home_cubit/home_cubit/home_cubit.dart';
import 'package:the_elsewheres/ui/view_models/home_cubit/home_cubit/home_state.dart';

class EventDetailsModal extends StatelessWidget {
  final NewEventModel event;
  final UserProfile userProfile;

  const EventDetailsModal({Key? key, required this.event, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primary,
                                colorScheme.primaryContainer,
                              ],
                            ),
                          ),
                          child: (event.eventImage.isNotEmpty)
                              ? Image.network(
                            event.eventImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.event,
                                  size: 64,
                                  color: colorScheme.onPrimary,
                                ),
                              );
                            },
                          )
                              : Center(
                            child: Icon(
                              Icons.event,
                              size: 64,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Event Name and Rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.eventName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: colorScheme.tertiary.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: colorScheme.tertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.rate.toStringAsFixed(1),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
                        ),
                        child: Text(
                          event.tag,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.eventDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Event Details
                      Text(
                        'Event Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDetailRow(context, 'Start Date', DateFormat('EEEE, MMMM dd, yyyy hh:mm a').format(event.startDate)),
                      _buildDetailRow(context, 'End Date', DateFormat('EEEE, MMMM dd, yyyy hh:mm a').format(event.endDate)),
                      _buildDetailRow(context, 'Campus', event.location.campus),
                      _buildDetailRow(context, 'Venue', event.location.place),

                      const SizedBox(height: 30),

                      // Action Buttons with Registration Logic
                      BlocConsumer<HomeCubit, HomeState>(
                        listener: (context, state) {
                          if (state is RegisterEventSuccessState) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: colorScheme.primary,
                              ),
                            );
                          } else if (state is RegisterEventErrorState) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.errorMessage),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          bool isLoading = state is RegisterEventLoadingState;

                          // Get current user ID and event ID
                          String userId = userProfile.id.toString();
                          String eventId = event.id.toString();

                          // Check if user is registered by looking at the registeredUsers list
                          bool isUserRegistered = event.registeredUsers?.contains(userId) ?? false;

                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : () {
                                    if (isUserRegistered) {
                                      // Unregister user
                                      context.read<HomeCubit>().unregisterFromEvent(userId, eventId);
                                    } else {
                                      // Register user
                                      context.read<HomeCubit>().registerToEvent(userId, eventId);
                                    }
                                  },
                                  icon: isLoading
                                      ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                                    ),
                                  )
                                      : Icon(
                                    isUserRegistered ? Icons.person_remove : Icons.person_add,
                                  ),
                                  label: Text(
                                    isLoading
                                        ? 'Loading...'
                                        : (isUserRegistered ? 'Unregister' : 'Register'),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isUserRegistered
                                        ? colorScheme.error
                                        : colorScheme.primary,
                                    foregroundColor: isUserRegistered
                                        ? colorScheme.onError
                                        : colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: isLoading ? null : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Event shared!'),
                                      backgroundColor: colorScheme.secondary,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.share),
                                label: const Text('Share'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.secondary,
                                  foregroundColor: colorScheme.onSecondary,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Show registered users count
                      if (event.registeredUsers != null && event.registeredUsers!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${event.registeredUsers!.length} people registered',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
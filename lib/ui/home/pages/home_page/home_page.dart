import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/ui/view_models/home_cubit/home_cubit.dart';
import 'package:the_elsewheres/ui/view_models/home_cubit/home_state.dart';

class HomePage extends StatefulWidget {
  final UserProfile? userProfile;
  final bool isStaff;

  const HomePage({
    super.key,
    required this.userProfile,
    this.isStaff = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize listening to events when the screen loads (only for non-staff)
    if (widget.isStaff) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomeCubit>().listenToUpComingEvents();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.userProfile?.login ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!widget.isStaff) ...[
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Staff',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Staff Actions Section
            Visibility(
              visible: !widget.isStaff,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Staff Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF667eea).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildStaffActionButton(
                          icon: Icons.add_circle_outline,
                          title: 'Add New Event',
                          subtitle: 'Create and manage events',
                          onTap: () => context.go('/home/add-event', extra: widget.userProfile),
                        ),
                        const SizedBox(height: 15),
                        _buildStaffActionButton(
                          icon: Icons.event_note,
                          title: 'Manage Events',
                          subtitle: 'View and edit existing events',
                          onTap: () => context.go('/home/manage-event', extra: widget.userProfile),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Student Events Section - Only visible when not staff
            Visibility(
              visible: widget.isStaff,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming Events',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          context.read<HomeCubit>().listenToUpComingEvents();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF667eea),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Events List with BLoC
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state is StudentListenUpComingLoadingState) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Loading events...',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is StudentListenUpComingErrorState) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Unable to load events',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<HomeCubit>().listenToUpComingEvents();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667eea),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is StudentListenUpComingSuccessState) {
                        if (state.events.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No upcoming events',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check back later for new events!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Column(
                          children: [
                            // Show first 3 events in compact view
                            ...state.events.take(3).map((event) => EventCompactCard(event: event, userProfile: widget.userProfile!,)),

                            if (state.events.length > 3) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF667eea).withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${state.events.length - 3} more events',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                        Text(
                                          'Tap to view all events',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _showAllEventsModal(context, state.events, widget.userProfile!);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF667eea),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('View All'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            // Quick Actions Section (visible for both staff and students)
            const SizedBox(height: 30),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 15),
            _buildQuickActionsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF667eea).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF667eea).withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.2,
      children: [
        _buildQuickActionCard(
          icon: Icons.event,
          title: 'Events',
          color: const Color(0xFF667eea),
        ),
        _buildQuickActionCard(
          icon: Icons.notifications,
          title: 'Notifications',
          color: const Color(0xFF764ba2),
        ),
        _buildQuickActionCard(
          icon: Icons.calendar_today,
          title: 'Calendar',
          color: const Color(0xFF4CAF50),
        ),
        _buildQuickActionCard(
          icon: Icons.settings,
          title: 'Settings',
          color: const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // Handle quick action taps
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title tapped')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAllEventsModal(BuildContext context, List<NewEventModel> events, UserProfile userProfile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AllEventsModal(events: events, userProfile: userProfile),
    );
  }
}

// Compact Event Card for Home Page
class EventCompactCard extends StatelessWidget {
  final NewEventModel event;
  final UserProfile userProfile;

  const EventCompactCard({Key? key, required this.event, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showEventDetails(context, event);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF667eea).withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              // Event Image/Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                ),
                child: (event.eventImage != null && event.eventImage!.isNotEmpty)
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    event.eventImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.event,
                        color: Colors.white,
                        size: 24,
                      );
                    },
                  ),
                )
                    : const Icon(
                  Icons.event,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Event Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(event.startDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location.campus,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amber.shade600,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      event.rate.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, NewEventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailsModal(event: event, userProfile: userProfile),
    );
  }
}

// All Events Modal
class AllEventsModal extends StatelessWidget {
  final List<NewEventModel> events;
  final UserProfile userProfile;

  const AllEventsModal({Key? key, required this.events, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      '${events.length} events',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Events List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return EventCompactCard(userProfile: userProfile, event: events[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Event Details Modal
// Updated EventDetailsModal with proper registration logic
class EventDetailsModal extends StatelessWidget {
  final NewEventModel event;
  final UserProfile userProfile;

  const EventDetailsModal({Key? key, required this.event, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
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
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF667eea),
                                Color(0xFF764ba2),
                              ],
                            ),
                          ),
                          child: (event.eventImage != null && event.eventImage!.isNotEmpty)
                              ? Image.network(
                            event.eventImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.event,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                              : const Center(
                            child: Icon(
                              Icons.event,
                              size: 64,
                              color: Colors.white,
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
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.rate.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.amber.shade800,
                                    fontSize: 14,
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
                          color: const Color(0xFF667eea).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF667eea).withOpacity(0.3)),
                        ),
                        child: Text(
                          event.tag,
                          style: const TextStyle(
                            color: Color(0xFF667eea),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.eventDescription,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Event Details
                      const Text(
                        'Event Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDetailRow('Start Date', DateFormat('EEEE, MMMM dd, yyyy').format(event.startDate)),
                      _buildDetailRow('End Date', DateFormat('EEEE, MMMM dd, yyyy').format(event.endDate)),
                      _buildDetailRow('Campus', event.location.campus),
                      _buildDetailRow('Venue', event.location.place),

                      const SizedBox(height: 30),

                      // Action Buttons with Registration Logic
                      BlocConsumer<HomeCubit, HomeState>(
                        listener: (context, state) {
                          if (state is RegisterEventSuccessState) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (state is RegisterEventErrorState) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.errorMessage),
                                backgroundColor: Colors.red,
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
                                      ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                                        ? Colors.red.shade600
                                        : const Color(0xFF667eea),
                                    foregroundColor: Colors.white,
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
                                    const SnackBar(
                                      content: Text('Event shared!'),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.share),
                                label: const Text('Share'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
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
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${event.registeredUsers!.length} people registered',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Also update the EventCompactCard to show registration status
// class EventCompactCard extends StatelessWidget {
//   final NewEventModel event;
//   final UserProfile userProfile;
//
//   const EventCompactCard({Key? key, required this.event, required this.userProfile}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Check if user is registered
//     bool isUserRegistered = event.registeredUsers?.contains(userProfile.id.toString()) ?? false;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: InkWell(
//         onTap: () {
//           _showEventDetails(context, event);
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//             border: Border.all(
//               color: isUserRegistered
//                   ? Colors.green.withOpacity(0.3)
//                   : const Color(0xFF667eea).withOpacity(0.1),
//             ),
//           ),
//           child: Row(
//             children: [
//               // Event Image/Icon
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   gradient: const LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Color(0xFF667eea),
//                       Color(0xFF764ba2),
//                     ],
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     // Main image/icon
//                     (event.eventImage != null && event.eventImage!.isNotEmpty)
//                         ? ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         event.eventImage!,
//                         fit: BoxFit.cover,
//                         width: 60,
//                         height: 60,
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Icon(
//                             Icons.event,
//                             color: Colors.white,
//                             size: 24,
//                           );
//                         },
//                       ),
//                     )
//                         : const Icon(
//                       Icons.event,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//
//                     // Registration status indicator
//                     if (isUserRegistered)
//                       Positioned(
//                         top: 2,
//                         right: 2,
//                         child: Container(
//                           padding: const EdgeInsets.all(2),
//                           decoration: BoxDecoration(
//                             color: Colors.green,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.check,
//                             color: Colors.white,
//                             size: 12,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(width: 12),
//
//               // Event Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             event.eventName,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF333333),
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         if (isUserRegistered)
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade50,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               'Registered',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.green.shade700,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       DateFormat('MMM dd, yyyy').format(event.startDate),
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.location_on,
//                           size: 14,
//                           color: Colors.grey[500],
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             event.location.campus,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[500],
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         // Show registered users count
//                         if (event.registeredUsers != null && event.registeredUsers!.isNotEmpty) ...[
//                           const SizedBox(width: 8),
//                           Icon(
//                             Icons.people,
//                             size: 12,
//                             color: Colors.grey[500],
//                           ),
//                           const SizedBox(width: 2),
//                           Text(
//                             '${event.registeredUsers!.length}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[500],
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Rating
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.amber.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.star,
//                       size: 14,
//                       color: Colors.amber.shade600,
//                     ),
//                     const SizedBox(width: 2),
//                     Text(
//                       event.rate.toStringAsFixed(1),
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.amber.shade800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showEventDetails(BuildContext context, NewEventModel event) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => EventDetailsModal(event: event, userProfile: userProfile),
//     );
//   }
// }
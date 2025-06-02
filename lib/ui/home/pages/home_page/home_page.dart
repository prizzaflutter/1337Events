import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:the_elsewheres/data/authentification/onesignal_notification_services.dart';
import 'package:the_elsewheres/dependency_injection/dependency_injection.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/usercases/check_user_has_access_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/add_new_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/get_userId_from_login_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/is_user_exit_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/update_user_club_admin_status_usecase.dart';
import 'package:the_elsewheres/ui/home/pages/home_page/home_page_wdigets/all_events_model_widget.dart';
import 'package:the_elsewheres/ui/home/pages/home_page/home_page_wdigets/event_compact_card_widget.dart';
import 'package:the_elsewheres/ui/home/pages/home_page/home_page_wdigets/get_access_dialog_widget.dart';
import 'package:the_elsewheres/ui/home/pages/new_event_page/add_event_page_for_clubadmin.dart';
import 'package:the_elsewheres/ui/home/widgets/pending_event_dialog_widget.dart';
import 'package:the_elsewheres/ui/view_models/event_cubit/upcoming_event_cubit/upcoming_cubit.dart';
import 'package:the_elsewheres/ui/view_models/home_cubit/feedback_cubit/feedback_cubit.dart';
import 'package:the_elsewheres/ui/view_models/home_cubit/home_cubit/home_cubit.dart';

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
    if (!widget.isStaff) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UpcomingCubit>().listenToUpComingEvents();
        context.read<FeedbackCubit>().listenToEventNeedFeedback(userId: widget.userProfile!.id.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with gradient
          SliverAppBar(
            expandedHeight: 210,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // User profile section with real-time club admin status
                        _buildUserProfileSection(colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              if (!widget.isStaff)
                IconButton(
                  icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
                  onPressed: () {
                    context.read<UpcomingCubit>().listenToUpComingEvents();
                  },
                ),
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: colorScheme.onPrimary),
                onPressed: () {
                  OneSignalNotificationService().showTestNotification();
                },
              ),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Staff Actions Section
                  Visibility(
                    visible: widget.isStaff,
                    child: _buildStaffManagementSection(colorScheme),
                  ),

                  _buildClubAdminSection(colorScheme),

                  // Staff Account Management Section
                  Visibility(
                    visible: widget.isStaff,
                    child: _buildAccountManagementSection(colorScheme),
                  ),

                  // Student Events Section - Only visible when not staff
                  Visibility(
                    visible: !widget.isStaff,
                    child: _buildUpcomingEventsSection(colorScheme),
                  ),

                  // Events that need feedback
                  SizedBox(height: 50.h),
                  Visibility(
                    visible: !widget.isStaff,
                    child: _buildFeedbackEventsSection(colorScheme),
                  ),
                  const SizedBox(height: 100), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.onPrimary, width: 3),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
                widget.userProfile?.image.versions.medium ??
                    'https://via.placeholder.com/120'
            ),
            backgroundColor: colorScheme.surfaceContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userProfile?.login ?? 'User',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Real-time club admin status using StreamBuilder
              StreamBuilder<bool>(
                stream: context.read<HomeCubit>().isClubMember(widget.userProfile?.id.toString() ?? ''),
                builder: (context, snapshot) {
                  final isClubAdmin = snapshot.data ?? false;
                    debugPrint("the isClubAdmin is $isClubAdmin");
                    debugPrint("the is staff is ${widget.isStaff}");
                  if (widget.isStaff || isClubAdmin) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.onPrimary.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.isStaff ? 'STAFF' : isClubAdmin ? 'CLUB ADMIN' : 'STUDENT',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClubAdminSection(ColorScheme colorScheme) {
    return StreamBuilder<bool>(
      stream: context.read<HomeCubit>().isClubMember(widget.userProfile?.id.toString() ?? ''),
      builder: (context, snapshot) {
        final isClubAdmin = snapshot.data ?? false;
        if (!isClubAdmin) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Club Admin Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            _buildStaffActionButton(
              icon: Icons.add_circle_outline,
              title: 'Add New Event',
              subtitle: 'Create and manage events',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddEventPageFroAdmin(userProfile: widget.userProfile!, addNewEventUseCase: getIt<AddNewEventUseCase>(), isClubAdmin: isClubAdmin))),
            ),
            SizedBox(height: 30.h),
          ],
        );
      },
    );
  }

  Widget _buildStaffManagementSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Events Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
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
    );
  }

  Widget _buildAccountManagementSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildStaffActionButton(
                icon: Icons.add_circle_outline,
                title: 'Give Access',
                subtitle: 'Add New Club Admin',
                onTap: () => showGrantAccessDialog(context,
                  onGrantAccess: (String userId, bool giveAccess) async =>
                  await getIt<UpdateUserClubAdminStatusUseCase>().call(userId, giveAccess),
                  checkUserExists: (String login) async =>
                  await getIt<IsUserExitUseCase>().call(login),
                  onRevokeAccess: (String userId) async =>
                  await getIt<UpdateUserClubAdminStatusUseCase>().call(userId, false),
                  checkUserHasAccess: (String username) async =>
                  await getIt<CheckUserHasAccessUseCase>().call(username),
                  getUserIdFromLoginUseCase: getIt<GetUserIdFromLoginUseCase>(),
                ),
              ),
              SizedBox(height: 15.h),
              _buildStaffActionButton(
                icon: Icons.pending_actions,
                title: 'Pending Events',
                subtitle: 'Allow/Revoke Club Admin event',
                onTap: () => showPendingEventsDialog(context)
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildUpcomingEventsSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Events',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 15),
        BlocBuilder<UpcomingCubit, UpcomingState>(
          builder: (context, state) {
            if (state is StudentListenUpComingLoadingState) {
              return _buildLoadingContainer(colorScheme);
            }

            if (state is StudentListenUpComingErrorState) {
              return _buildErrorContainer(colorScheme, state.errorMessage, () {
                context.read<UpcomingCubit>().listenToUpComingEvents();
              });
            }

            if (state is StudentListenUpComingSuccessState) {
              if (state.events.isEmpty) {
                return _buildEmptyEventsContainer(colorScheme);
              }
              return _buildEventsListContainer(state.events, colorScheme);
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildFeedbackEventsSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Events that need feedback',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 15),
        BlocBuilder<FeedbackCubit, FeedbackState>(
          builder: (context, state) {
            if (state is EventNeedFeedbackLoading) {
              return _buildLoadingContainer(colorScheme);
            }

            if (state is EventNeedFeedbackError) {
              return _buildErrorContainer(colorScheme, state.errorMessage, () {
                context.read<FeedbackCubit>().listenToEventNeedFeedback(
                    userId: widget.userProfile!.id.toString());
              });
            }

            if (state is EventNeedFeedbackLoaded) {
              if (state.newEventModelList.isEmpty) {
                return _buildEmptyEventsContainer(colorScheme);
              }
              return _buildFeedbackEventsListContainer(state.newEventModelList, colorScheme);
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingContainer(ColorScheme colorScheme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading events...',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyEventsContainer(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainer,
            colorScheme.surfaceContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Animated icon container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Main title
          Text(
            'No Events Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'New exciting events will appear here.\nStay tuned for updates!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Decorative elements
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDecorativeDot(colorScheme.primary.withOpacity(0.3)),
              const SizedBox(width: 8),
              _buildDecorativeDot(colorScheme.primary.withOpacity(0.6)),
              const SizedBox(width: 8),
              _buildDecorativeDot(colorScheme.primary),
              const SizedBox(width: 8),
              _buildDecorativeDot(colorScheme.primary.withOpacity(0.6)),
              const SizedBox(width: 8),
              _buildDecorativeDot(colorScheme.primary.withOpacity(0.3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContainer(ColorScheme colorScheme, String errorMessage, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainer,
            colorScheme.errorContainer.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.error.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Error icon with animated container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.errorContainer,
                  colorScheme.errorContainer.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.error.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 24),

          // Main title
          Text(
            'Connection Issue',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Error message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.error.withOpacity(0.2),
              ),
            ),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onErrorContainer,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Retry button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: colorScheme.onPrimary,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Help text
          Text(
            'Pull down to refresh or check your connection',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

// Helper method for decorative dots
  Widget _buildDecorativeDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }


// Helper method for decorative dots

  Widget _buildEventsListContainer(List<NewEventModel> events, ColorScheme colorScheme) {
    return Column(
      children: [
        ...events.take(3).map((event) => EventCompactCard(
            event: event, userProfile: widget.userProfile!, isDetails: true)),

        if (events.length > 3) ...[
          const SizedBox(height: 16),
          _buildViewAllEventsButton(events, colorScheme, 'View All'),
        ],
      ],
    );
  }

  Widget _buildFeedbackEventsListContainer(List<NewEventModel> events, ColorScheme colorScheme) {
    return Column(
      children: [
        ...events.take(3).map((event) => EventCompactCard(
            event: event, userProfile: widget.userProfile!, isDetails: false)),

        if (events.length > 3) ...[
          const SizedBox(height: 16),
          _buildViewAllEventsButton(events, colorScheme, 'View All'),
        ],
      ],
    );
  }

  Widget _buildViewAllEventsButton(List<NewEventModel> events, ColorScheme colorScheme, String buttonText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${events.length - 3} more events',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                'Tap to view all events',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              _showAllEventsModal(context, events, widget.userProfile!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimary,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onPrimaryContainer.withOpacity(0.5),
            ),
          ],
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
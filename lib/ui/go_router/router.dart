// Simplified app_router.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_elsewheres/dependency_injection/dependency_injection.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/get_user_profile_usecase.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/is_logged_in_usecase.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/logged_out_usecase.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/add_new_event_usecase.dart';
import 'package:the_elsewheres/ui/home/home_screen.dart';
import 'package:the_elsewheres/ui/home/pages/error_page.dart';
import 'package:the_elsewheres/ui/home/pages/manage_events/Edit_event.dart';
import 'package:the_elsewheres/ui/home/pages/manage_events/manage_event_widget/qr_check_widget.dart';
import 'package:the_elsewheres/ui/home/pages/manage_events/manage_events.dart';
import 'package:the_elsewheres/ui/home/pages/new_event_page/add_event_page.dart';
import 'package:the_elsewheres/ui/home/pages/profile_page.dart';
import 'package:the_elsewheres/ui/login/login_page.dart';
import 'package:the_elsewheres/ui/splash_screen.dart';

// Create a data class to pass both event and user profile
class EditEventData {
  final NewEventModel event;
  final UserProfile userProfile;

  EditEventData({required this.event, required this.userProfile});
}

// Helper function to safely get UserProfile from state.extra
UserProfile? _getUserProfileFromExtra(Object? extra) {
  if (extra == null) return null;

  // If it's already a UserProfile, return it
  if (extra is UserProfile) {
    return extra;
  }

  // If it's a Map, try to create UserProfile from it
  if (extra is Map<String, dynamic>) {
    try {
      return UserProfile.fromJson(extra);
    } catch (e) {
      if (kDebugMode) {
        print('Error converting map to UserProfile: $e');
      }
      return null;
    }
  }

  // For any other type, return null
  if (kDebugMode) {
    print('Unexpected extra type: ${extra.runtimeType}');
  }
  return null;
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => ErrorPage(error: state.error),
  routes: [
    GoRoute(
      path: '/',
      name: 'splash_screen',
      builder: (context, state) => SplashScreen(
        isLoggedInUseCase: getIt<IsLoggedInUseCase>(),
        getUserProfileUseCase: getIt<GetUserProfileUseCase>(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) {
        // Use the helper function to safely get UserProfile
        UserProfile? userProfile = _getUserProfileFromExtra(state.extra);

        if (userProfile == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const SizedBox.shrink();
        }

        return HomeScreen(userProfile: userProfile);
      },
      routes: [
        GoRoute(
          path: 'add-event',
          name: 'add_event',
          builder: (context, state) {
            final UserProfile? userProfile = _getUserProfileFromExtra(state.extra);

            if (userProfile == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/login');
              });
              return const SizedBox.shrink();
            }

            // Uncomment if you need staff permission checks
            // if (!(userProfile.isStaff)) {
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     context.go('/home', extra: userProfile);
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(
            //         behavior: SnackBarBehavior.floating,
            //         content: Text('You need staff permissions to add events'),
            //         backgroundColor: Colors.red,
            //       ),
            //     );
            //   });
            //   return const SizedBox.shrink();
            // }

            return AddEventPage(
              userProfile: userProfile,
              addNewEventUseCase: getIt<AddNewEventUseCase>(),
            );
          },
        ),
        GoRoute(
          path: 'manage-event',
          name: 'manage_event',
          builder: (context, state) {
            final UserProfile? userProfile = _getUserProfileFromExtra(state.extra);

            if (userProfile == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/login');
              });
              return const SizedBox.shrink();
            }

            // Uncomment if you need staff permission checks
            // if (!(userProfile.isStaff)) {
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     context.go('/home', extra: userProfile);
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(
            //         behavior: SnackBarBehavior.floating,
            //         content: Text('You need staff permissions to manage events'),
            //         backgroundColor: Colors.red,
            //       ),
            //     );
            //   });
            //   return const SizedBox.shrink();
            // }

            return ManageEvents(userProfile: userProfile);
          },
          routes: [
            GoRoute(
              path: 'edit-event',
              name: 'edit-event',
              builder: (context, state) {
                // Handle EditEventData or NewEventModel
                final extra = state.extra;

                if (extra == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go('/home/manage-event');
                  });
                  return const SizedBox.shrink();
                }

                // If it's EditEventData
                if (extra is EditEventData) {
                  return EditEventPage(
                    event: extra.event,
                  );
                }

                // If it's just NewEventModel, you'll need to get userProfile somehow
                if (extra is NewEventModel) {
                  // You might need to pass UserProfile separately or get it from somewhere
                  // For now, redirect back to manage events
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go('/home/manage-event');
                  });
                  return const SizedBox.shrink();
                }

                // Unknown type, redirect
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go('/home/manage-event');
                });
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) {
        final userProfile = _getUserProfileFromExtra(state.extra);

        if (userProfile == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const SizedBox.shrink();
        }

        return ProfilePage(
          userProfile: userProfile,
          logOutUseCase: getIt<LogOutUseCase>(),
        );
      },
    ),
    GoRoute(
      path: '/event-visited',
      builder: (context, state) {
        final eventId = state.uri.queryParameters['eventId'];
        return QrCheckWidget(eventId: eventId!,);
      },
    ),
  ],
);
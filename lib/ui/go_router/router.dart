// Simplified app_router.dart
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

    // todo: problem is here when i navigate from edit-page to home page
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) {
      UserProfile? userProfile = state.extra as UserProfile?;
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
            final UserProfile? userProfile = state.extra as UserProfile?;

            if (userProfile == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/login');
              });
              return const SizedBox.shrink();
            }

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
            final  UserProfile? userProfile = state.extra as UserProfile?;

            if (userProfile == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/login');
              });
              return const SizedBox.shrink();
            }

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
          // routes: [
          //   GoRoute(
          //     path: 'edit-event',
          //     name: 'edit-event',
          //     builder: (context, state) {
          //       // Try to cast to EditEventData first
          //       final NewEventModel? editData = state.extra as NewEventModel;
          //
          //       if (editData == null) {
          //         WidgetsBinding.instance.addPostFrameCallback((_) {
          //           context.go('/manage-event');
          //         });
          //         return const SizedBox.shrink();
          //       }
          //
          //       // // Check staff permissions
          //       // if (!(editData.userProfile.isStaff)) {
          //       //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //       //     context.go('/home', extra: editData.userProfile);
          //       //     ScaffoldMessenger.of(context).showSnackBar(
          //       //       const SnackBar(
          //       //         behavior: SnackBarBehavior.floating,
          //       //         content: Text('You need staff permissions to edit events'),
          //       //         backgroundColor: Colors.red,
          //       //       ),
          //       //     );
          //       //   });
          //       //   return const SizedBox.shrink();
          //       // }
          //
          //       return EditEventPage(
          //         event: editData,
          //       );
          //     },
          //   ),
          // ]
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) {
        final userProfile = state.extra as UserProfile?;

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
  ],
);
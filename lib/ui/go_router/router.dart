// Fixed app_router.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:the_elsewheres/data/Oauth/services/o_auth_service.dart';
import 'package:the_elsewheres/dependency_injection/dependency_injection.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/get_user_profile_usecase.dart';
import 'package:the_elsewheres/ui/go_router/router.dart';
import 'package:the_elsewheres/ui/home/home_screen.dart';
import 'package:the_elsewheres/ui/home/pages/default_page.dart';
import 'package:the_elsewheres/ui/home/pages/error_page.dart';
import 'package:the_elsewheres/ui/home/pages/profile_page.dart';
import 'package:the_elsewheres/ui/login/login_page.dart';

Future<bool> _checkAuthStatus() async {
  return await OAuthService().isLoggedIn();
}

final GoRouter router = GoRouter(
  initialLocation: '/default',

  redirect: (BuildContext context, GoRouterState state) async {
    final isAuthenticated = await _checkAuthStatus();

    final isLoggingIn = state.matchedLocation == '/login';
    final isOnDefault = state.matchedLocation == '/default';
    if (!isAuthenticated && !isLoggingIn && !isOnDefault) {
      return '/login';
    }
    if (isAuthenticated && isLoggingIn) {
      return '/home';
    }
    if (isAuthenticated && isOnDefault) {
      return '/home';
    }

    return null;
  },

  // Error handling
  errorBuilder: (context, state) => ErrorPage(error: state.error),

  // Route definitions
  routes: [
    // Default/Splash route
    GoRoute(
      path: '/default',
      name: 'default',
      builder: (context, state) =>  DefaultPage(getUserProfileUseCase: getIt<GetUserProfileUseCase>(),),
    ),

    // Login route
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Home route with nested routes
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state){
       UserProfile? userProfile = state.extra as UserProfile?;
       if (userProfile != null)
       {
         return  HomeScreen( userProfile: userProfile,) ;
       }
       return  DefaultPage(getUserProfileUseCase: getIt<GetUserProfileUseCase>());
      },
      routes: [
        // Nested routes under home
        GoRoute(
          path: 'profile',
          name: 'profile',
          builder: (context, state){
            UserProfile? userProfile = state.extra as UserProfile?;
            if (userProfile != null) {
              return ProfilePage(userProfile: userProfile);
            }
            return DefaultPage(getUserProfileUseCase: getIt<GetUserProfileUseCase>());
          },
        ),
      ],
    ),
  ],
);


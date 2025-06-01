import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/get_user_profile_usecase.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/is_logged_in_usecase.dart';

class SplashScreen extends StatefulWidget {
  final IsLoggedInUseCase isLoggedInUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  const SplashScreen({super.key, required this.isLoggedInUseCase, required this.getUserProfileUseCase});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }
  Future<void> _checkAuthAndRedirect() async {
    final isAuthenticated = await widget.isLoggedInUseCase.call();
    if (mounted) {
      UserProfile? userProfile = await widget.getUserProfileUseCase.call();
      if (isAuthenticated && userProfile != null)  {
        debugPrint("User is authenticated: ${userProfile.toJson()}");
        context.go('/home', extra: userProfile);
        FlutterNativeSplash.remove();
      } else {
        debugPrint("navigate to login page");
        context.go('/login');
        FlutterNativeSplash.remove();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.shrink(),
    );
  }
}


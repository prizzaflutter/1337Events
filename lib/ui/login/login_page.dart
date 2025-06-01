import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:the_elsewheres/dependency_injection/dependency_injection.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/ui/view_models/login_cubit/login_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Check login status when screen initializes
    context.read<LoginCubit>().checkLoginStatus();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToHome(UserProfile userProfile) {
    // Replace with your actual home screen navigation
    // Navigator.pushReplacementNamed(context, '/home');
    debugPrint("Navigating to home screen");
    context.go('/home', extra: userProfile);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00BABC), // 42 teal color
                Color(0xFF00A8AA),
                Color(0xFF008B8D),
              ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: BlocConsumer<LoginCubit, LoginState>(
                    listener: (context, state) {
                      // Handle state changes that require side effects
                      if (state is LoginSuccess) {
                        _showSuccessMessage(state.message.toString());
                        _navigateToHome(state.userProfile);
                      } else if (state is LoginAlreadyAuthenticated) {
                        _navigateToHome(state.userProfile!);
                      }
                    },
                    builder: (context, state) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 42 Logo and Title
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Text(
                              "42",
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00BABC),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Welcome Text
                          const Text(
                            "Welcome to",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const Text(
                            "The Elsewheres",
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Status message based on state
                          Text(
                            _getStatusMessage(state),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 60),

                          // Error Message
                          if (state is LoginError)
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade700),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      state.message,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => context.read<LoginCubit>().clearError(),
                                    icon: Icon(Icons.close, color: Colors.red.shade700),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _shouldDisableButton(state)
                                  ? null
                                  : () => context.read<LoginCubit>().login(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF00BABC),
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _buildButtonContent(state),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Footer
                          Text(
                            "By continuing, you agree to our Terms of Service",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusMessage(LoginState state) {
    if (state is LoginCheckingStatus) {
      return "Checking authentication status...";
    } else if (state is LoginCancelled) {
      return "Authentication was cancelled. Try again.";
    } else {
      return "Connect with your 42 account to continue";
    }
  }

  bool _shouldDisableButton(LoginState state) {
    return state is LoginLoading ||
        state is LoginCheckingStatus ||
        state is LoginSuccess ||
        state is LoginAlreadyAuthenticated;
  }

  Widget _buildButtonContent(LoginState state) {
    if (state is LoginLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF00BABC),
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            "Authenticating...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else if (state is LoginCheckingStatus) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF00BABC),
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            "Checking status...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF00BABC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "42",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Continue with 42",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
  }
}
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:the_elsewheres/data/Oauth/services/o_auth_service.dart';
import 'package:the_elsewheres/data/authentification/onesignal_notification_services.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/authenticate_usecase.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/get_user_profile_usecase.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/is_logged_in_usecase.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/logged_out_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/save_user_profile_usecase.dart';

part 'login_state.dart';


// Login Cubit
class LoginCubit extends Cubit<LoginState> {
  final AuthenticateUseCase _authenticateUseCase;
  final SaveUserProfileUseCase _saveUserProfileToFirestore;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;
  final LogOutUseCase _logOutUseCase;


  LoginCubit(this._saveUserProfileToFirestore, this._authenticateUseCase, this._logOutUseCase, this._getUserProfileUseCase, this._isLoggedInUseCase):
        super(LoginInitial());

  /// Check if user is already logged in
  Future<void> checkLoginStatus() async {
    emit(LoginCheckingStatus());

    try {
      final isLoggedIn = await _isLoggedInUseCase.call();

      if (isLoggedIn) {
        debugPrint("User is already logged in");
       UserProfile? userProfile =  await _getUserProfileUseCase.call();
        emit(LoginAlreadyAuthenticated(userProfile:  userProfile));
      } else {
        debugPrint("User is not logged in");
        emit(LoginInitial());
      }
    } catch (e) {
      debugPrint("Error checking login status: $e");
      emit(LoginError(message: "Failed to check login status. Please try again."));
    }
  }

  /// Perform login authentication
  Future<void> login(BuildContext context) async {
    emit(LoginLoading());

    try {
      final client = await _authenticateUseCase.call(context);

      if (client != null) {
        debugPrint("Authenticated successfully");
        UserProfile? userProfile = await _getUserProfileUseCase.call();
        if (userProfile != null){
          await OneSignal.login(userProfile.id.toString());
          await _saveUserProfileToFirestore.call(userProfile);
          emit(LoginSuccess(userProfile: userProfile,  message : "Successfully authenticated with 42!"));
        }else
        {
          debugPrint("User profile is null after authentication");
          emit(LoginError(message: "Failed to retrieve user profile. Please try again."));
        }
      } else {
        emit(LoginCancelled());
      }
    } catch (e) {
      debugPrint("Authentication error: $e");
      emit(LoginError(message: _getErrorMessage(e.toString())));
    }
  }

  /// Reset state to initial
  void resetState() {
    emit(LoginInitial());
  }

  /// Clear error state
  void clearError() {
    emit(LoginInitial());
  }

  /// Get user-friendly error message
  String _getErrorMessage(String error) {
    if (error.contains("network") || error.contains("connection")) {
      return "Network error. Please check your internet connection.";
    } else if (error.contains("timeout")) {
      return "Request timed out. Please try again.";
    } else if (error.contains("invalid_client")) {
      return "Authentication configuration error. Please contact support.";
    } else if (error.contains("access_denied")) {
      return "Access denied. Please check your credentials.";
    } else {
      return "Authentication failed. Please try again.";
    }
  }

}

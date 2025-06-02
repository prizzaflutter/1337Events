import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_elsewheres/domain/firebase/model/feedback_model.dart';
import 'dart:async';
import 'package:the_elsewheres/domain/firebase/usercases/register_unregister_usecase/register_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/submet_feedback_usecase.dart';
import 'package:the_elsewheres/ui/view_models/home_cubit/home_cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final SubmitFeedBackUseCase submitFeedBackUseCase;
  final RegisterUseCase registerUseCase;

  HomeCubit( this.registerUseCase, this.submitFeedBackUseCase)
      : super(HomeInitial());


  Future<void> submitFeedback(String eventId,
      FeedBackModel feedback,) async {
    emit(SubmitFeedbackLoadingState());

    try {
      await submitFeedBackUseCase.call(eventId: eventId, feedback: feedback);
      emit(SubmitFeedbackSuccessState('Feedback submitted successfully.'));
    } catch (error) {
      String errorMessage;

      if (error is FirebaseException) {
        switch (error.code) {
          case 'failed-precondition':
            errorMessage = 'Database index required. Please contact support.';
            break;
          case 'permission-denied':
            errorMessage =
            'Permission denied. Please check your access rights.';
            break;
          case 'unavailable':
            errorMessage = 'Service temporarily unavailable. Please try again.';
            break;
          default:
            errorMessage = 'Database error: ${error.message ?? error.code}';
        }
      } else if (error is Exception) {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = 'An unexpected error occurred: $error';
      }

      emit(SubmitFeedbackErrorState(errorMessage));
    }
  }

  Future<void> registerToEvent(String userId, String eventId) async {
    emit(RegisterEventLoadingState());

    try {
      await registerUseCase.register(userId, eventId);
      emit(RegisterEventSuccessState('Successfully registered to the event.'));
    } catch (error) {
      String errorMessage;

      if (error is FirebaseException) {
        switch (error.code) {
          case 'failed-precondition':
            errorMessage = 'Database index required. Please contact support.';
            break;
          case 'permission-denied':
            errorMessage =
            'Permission denied. Please check your access rights.';
            break;
          case 'unavailable':
            errorMessage = 'Service temporarily unavailable. Please try again.';
            break;
          default:
            errorMessage = 'Database error: ${error.message ?? error.code}';
        }
      } else if (error is Exception) {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = 'An unexpected error occurred: $error';
      }

      emit(RegisterEventErrorState(errorMessage));
    }
  }

  Future<void> unregisterFromEvent(String userId, String eventId) async {
    emit(RegisterEventLoadingState());

    try {
      await registerUseCase.unregister(userId, eventId);
      emit(RegisterEventSuccessState(
          'Successfully unregistered from the event.'));
    } catch (error) {
      String errorMessage;

      if (error is FirebaseException) {
        switch (error.code) {
          case 'failed-precondition':
            errorMessage = 'Database index required. Please contact support.';
            break;
          case 'permission-denied':
            errorMessage =
            'Permission denied. Please check your access rights.';
            break;
          case 'unavailable':
            errorMessage = 'Service temporarily unavailable. Please try again.';
            break;
          default:
            errorMessage = 'Database error: ${error.message ?? error.code}';
        }
      } else if (error is Exception) {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = 'An unexpected error occurred: $error';
      }

      emit(RegisterEventErrorState(errorMessage));
    }
  }

  // i want to make stream to get just is Club from the user_profiles
  Stream<bool> isClubMember(String userId) {
    return FirebaseFirestore.instance
        .collection('user_profiles')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        return data['is_club_admin'] ?? false; // Default to false if not found
      }
      return false; // Default to false if document does not exist
    });
  }

}
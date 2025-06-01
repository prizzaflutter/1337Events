import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/student_listen_to_upcoming_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/register_unregister_usecase/register_usecase.dart';
import 'package:the_elsewheres/ui/view_models/home_cubit/home_cubit.dart';
import 'package:the_elsewheres/ui/view_models/home_cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final StudentListenToUpComingEventUseCase upComingEventUseCase;
  final RegisterUseCase registerUseCase;
  StreamSubscription? _eventsSubscription;

  HomeCubit(this.upComingEventUseCase, this.registerUseCase) : super(HomeInitial());

  void listenToUpComingEvents() {
    emit(StudentListenUpComingLoadingState());

    _eventsSubscription?.cancel();

    _eventsSubscription = upComingEventUseCase.call()
        .listen(
          (events) {
        emit(StudentListenUpComingSuccessState(events));
      },
      onError: (error) {
        String errorMessage;

        if (error is FirebaseException) {
          switch (error.code) {
            case 'failed-precondition':
              errorMessage = 'Database index required. Please contact support.';
              break;
            case 'permission-denied':
              errorMessage = 'Permission denied. Please check your access rights.';
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

        emit(StudentListenUpComingErrorState(errorMessage));
      },
    );
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
            errorMessage = 'Permission denied. Please check your access rights.';
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
      emit(RegisterEventSuccessState('Successfully unregistered from the event.'));
    } catch (error) {
      String errorMessage;

      if (error is FirebaseException) {
        switch (error.code) {
          case 'failed-precondition':
            errorMessage = 'Database index required. Please contact support.';
            break;
          case 'permission-denied':
            errorMessage = 'Permission denied. Please check your access rights.';
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

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    return super.close();
  }
}

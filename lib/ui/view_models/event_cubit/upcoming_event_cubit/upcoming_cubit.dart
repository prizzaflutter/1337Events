import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/student_listen_to_upcoming_event_usecase.dart';

part 'upcoming_state.dart';

class UpcomingCubit extends Cubit<UpcomingState> {
  final StudentListenToUpComingEventUseCase upComingEventUseCase;
  StreamSubscription? _eventsSubscription;

  UpcomingCubit(this.upComingEventUseCase) : super(UpcomingInitial());

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
              errorMessage =
              'Permission denied. Please check your access rights.';
              break;
            case 'unavailable':
              errorMessage =
              'Service temporarily unavailable. Please try again.';
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

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    return super.close();
  }
}

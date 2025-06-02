import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/listen_to_pending_event_usecase.dart';

part 'append_state.dart';

class AppendCubit extends Cubit<AppendState> {

  final ListenToPendingEventUseCase appendingEventUseCase;
  StreamSubscription? _streamSubscription;

  AppendCubit(this.appendingEventUseCase) : super(AppendInitial());

  void listenToAppendEvent() {
    emit(AppendLoading());

    _streamSubscription?.cancel();

    _streamSubscription = appendingEventUseCase.call()
        .listen(
          (events) {
        emit(AppendLoaded(events));
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

        emit(AppendError(errorMessage));
      },
    );
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}

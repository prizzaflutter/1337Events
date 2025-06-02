import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/event_need_feedback_usecase.dart';

part 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final EventNeedFeedbackUseCase _eventNeedFeedbackUseCase;
  FeedbackCubit(this._eventNeedFeedbackUseCase, ) : super(FeedbackInitial());

  void listenToEventNeedFeedback({required String userId}) {
    emit(EventNeedFeedbackLoading());
    _eventNeedFeedbackUseCase.call(userId: userId).listen((eventList) {
      if (eventList.isEmpty) {
        emit(EventNeedFeedbackError("No events need feedback at the moment."));
      } else {
        emit(EventNeedFeedbackLoaded(eventList));
      }
    }, onError: (error) {
      emit(EventNeedFeedbackError(error.toString()));
    });
  }

}

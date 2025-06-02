
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';


// States
abstract class HomeState {}

class HomeInitial extends HomeState {}

// todo : register/unregister events
class RegisterEventLoadingState extends HomeState {}
class RegisterEventSuccessState extends HomeState {
  final String message;
  RegisterEventSuccessState(this.message);
}
class RegisterEventErrorState extends HomeState {
  final String errorMessage;
  RegisterEventErrorState(this.errorMessage);
}

// todo : submit feedback
class SubmitFeedbackLoadingState extends HomeState {}
class SubmitFeedbackSuccessState extends HomeState {
  final String message;
  SubmitFeedbackSuccessState(this.message);
}
class SubmitFeedbackErrorState extends HomeState {
  final String errorMessage;
  SubmitFeedbackErrorState(this.errorMessage);
}
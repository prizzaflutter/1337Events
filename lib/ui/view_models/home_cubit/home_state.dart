
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';


// States
abstract class HomeState {}

class HomeInitial extends HomeState {}

class StudentListenUpComingLoadingState extends HomeState {}

class StudentListenUpComingSuccessState extends HomeState {
  final List<NewEventModel> events;
  StudentListenUpComingSuccessState(this.events);
}

class StudentListenUpComingErrorState extends HomeState {
  final String errorMessage;
  StudentListenUpComingErrorState(this.errorMessage);
}

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
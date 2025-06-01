part of 'event_cubit.dart';

@immutable
sealed class EventState extends Equatable{}

final class EventInitial extends EventState {
  @override
  List<Object?> get props => [];
}

// todo: add new event states
class AddNewEventLoadingState extends EventState {
  @override
  List<Object?> get props => [];
}
class AddNewEventSuccessState extends EventState {
  @override
  List<Object?> get props => [];
}
class AddNewEventErrorState extends EventState {
  final String errorMessage;

  AddNewEventErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}


// todo : update event states
class UpdateNewEventLoadingState extends EventState {
  @override
  List<Object?> get props => [];
}
class UpdateNewEventSuccessState extends EventState {
  @override
  List<Object?> get props => [];
}
class UpdateNewEventErrorState extends EventState {
  final String errorMessage;

  UpdateNewEventErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// todo : delete event states
class DeleteEventLoadingState extends EventState {
  @override
  List<Object?> get props => [];
}
class DeleteEventSuccessState extends EventState {
  @override
  List<Object?> get props => [];
}
class DeleteEventErrorState extends EventState {
  final String errorMessage;

  DeleteEventErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// listen events for staff
class StaffListenEventLoadingState extends EventState {
  @override
  List<Object?> get props => [];
}
class StaffListenEventSuccessState extends EventState {
  final List<NewEventModel> events;

  StaffListenEventSuccessState(this.events);

  @override
  List<Object?> get props => [events];
}
class StaffListenEventErrorState extends EventState {
  final String errorMessage;

  StaffListenEventErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// listen events for student
class StudentListenEventLoadingState extends EventState {
  @override
  List<Object?> get props => [];
}
class StudentListenEventSuccessState extends EventState {
  final List<NewEventModel> events;

  StudentListenEventSuccessState(this.events);

  @override
  List<Object?> get props => [events];
}
class StudentListenEventErrorState extends EventState {
  final String errorMessage;

  StudentListenEventErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

part of 'home_cubit.dart';

@immutable
sealed class HomeState  extends Equatable {}

final class HomeInitial extends HomeState {
  @override
  List<Object?> get props => [];
}



// todo: add new event states
class AddNewEventLoadingState extends HomeState {
  @override
  List<Object?> get props => [];
}
class AddNewEventSuccessState extends HomeState {
  @override
  List<Object?> get props => [];
}
class AddNewEventErrorState extends HomeState {
  final String errorMessage;

  AddNewEventErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}


// todo : update event states
class UpdateNewEventLoadingState extends HomeState {
  @override
  List<Object?> get props => [];
}
class UpdateNewEventSuccessState extends HomeState {
  @override
  List<Object?> get props => [];
}
class UpdateNewEventErrorState extends HomeState {
  final String errorMessage;

  UpdateNewEventErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// todo : delete event states
class DeleteEventLoadingState extends HomeState {
  @override
  List<Object?> get props => [];
}
class DeleteEventSuccessState extends HomeState {
  @override
  List<Object?> get props => [];
}
class DeleteEventErrorState extends HomeState {
  final String errorMessage;

  DeleteEventErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

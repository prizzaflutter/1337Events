part of 'home_cubit.dart';

@immutable
sealed class HomeState  extends Equatable {}

final class HomeInitial extends HomeState {
  @override
  List<Object?> get props => [];
}

// listen to upcoming event states
// listen events for staff
class  StudentListenUpComingLoadingState extends HomeState {
  @override
  List<Object?> get props => [];
}
class StudentListenUpComingSuccessState extends HomeState {
  final List<NewEventModel> events;

  StudentListenUpComingSuccessState(this.events);

  @override
  List<Object?> get props => [events];
}
class StudentListenUpComingErrorState extends HomeState {
  final String errorMessage;

  StudentListenUpComingErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

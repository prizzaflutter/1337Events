part of 'upcoming_cubit.dart';

@immutable
sealed class UpcomingState {}

final class UpcomingInitial extends UpcomingState {}

class StudentListenUpComingLoadingState extends UpcomingState {}

class StudentListenUpComingSuccessState extends UpcomingState {
  final List<NewEventModel> events;
  StudentListenUpComingSuccessState(this.events);
}

class StudentListenUpComingErrorState extends UpcomingState {
  final String errorMessage;
  StudentListenUpComingErrorState(this.errorMessage);
}

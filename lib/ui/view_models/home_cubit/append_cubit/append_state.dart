part of 'append_cubit.dart';

@immutable
sealed class AppendState extends Equatable {}

final class AppendInitial extends AppendState {
  @override
  List<Object?> get props => [];
}
final class AppendLoading extends AppendState {
  @override
  List<Object?> get props => [];
}
final class AppendLoaded extends AppendState {
  final List<NewEventModel> eventModels;

  AppendLoaded(this.eventModels);

  @override
  List<Object?> get props => [eventModels];
}
final class AppendError extends AppendState {
  final String errorMessage;

  AppendError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}


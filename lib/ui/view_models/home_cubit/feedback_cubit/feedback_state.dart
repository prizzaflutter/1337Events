part of 'feedback_cubit.dart';

@immutable
sealed class FeedbackState extends Equatable{}

final class FeedbackInitial extends FeedbackState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

// event need feedback states
final class EventNeedFeedbackLoading extends FeedbackState {
  @override
  List<Object?> get props => [];
}
final class EventNeedFeedbackLoaded extends FeedbackState {
  final List<NewEventModel> newEventModelList;

  EventNeedFeedbackLoaded(this.newEventModelList);

  @override
  List<Object?> get props => [newEventModelList];
}
final class EventNeedFeedbackError extends FeedbackState {
  final String errorMessage;

  EventNeedFeedbackError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

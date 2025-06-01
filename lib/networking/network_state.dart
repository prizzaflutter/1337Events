part of 'network_cubit.dart';

@immutable
sealed class NetworkState extends Equatable{}

final class NetworkInitial extends NetworkState {
  @override
  List<Object?> get props => [];
}
final class NetworkConnected extends NetworkState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

final class NetworkDisconnected extends NetworkState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

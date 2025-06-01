part of 'login_cubit.dart';

@immutable
sealed class LoginState extends Equatable {}

final class LoginInitial extends LoginState {
  @override
  List<Object?> get props => [];
}


class LoginLoading extends LoginState {
  @override
  List<Object?> get props => [];
}

class LoginCheckingStatus extends LoginState {
  @override
  List<Object?> get props => [];
}

class LoginSuccess extends LoginState {
  final UserProfile userProfile;
  final String? message;
  LoginSuccess({required this.userProfile, required this.message});

  @override
  List<Object?> get props => [userProfile];
}

class LoginAlreadyAuthenticated extends LoginState {
  final UserProfile? userProfile;
  LoginAlreadyAuthenticated({required this.userProfile});
  @override
  List<Object?> get props => [userProfile];
}

class LoginError extends LoginState {
  final String message;
  LoginError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LoginCancelled extends LoginState {
  @override
  List<Object?> get props => [];
}

import 'package:the_elsewheres/domain/Oauth/repositories/o_auth_repository.dart';

class LogOutUseCase {
  final OAuthRepository _repository;

  LogOutUseCase(this._repository);

  Future<void> call() async {
    await _repository.logout();
  }
}
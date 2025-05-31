import 'package:the_elsewheres/domain/Oauth/repositories/o_auth_repository.dart';

class IsLoggedInUseCase {
  final OAuthRepository _oauthRepository;

  IsLoggedInUseCase(this._oauthRepository);

  Future<bool> call() async {
    return await _oauthRepository.isLoggedIn();
  }
}
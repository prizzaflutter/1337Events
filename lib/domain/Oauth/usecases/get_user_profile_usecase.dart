import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/Oauth/repositories/o_auth_repository.dart';

class GetUserProfileUseCase {
  final OAuthRepository _userRepository;

  GetUserProfileUseCase(this._userRepository);
  // todo : i will use a user model over here later
  Future<UserProfile> call() async {
    return await _userRepository.getUserProfile();
  }
}
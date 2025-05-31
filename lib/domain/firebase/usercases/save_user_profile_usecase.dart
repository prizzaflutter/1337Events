import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class SaveUserProfileUseCase{
  final FirebaseRepository _firebaseRepository;

  SaveUserProfileUseCase(this._firebaseRepository);

  Future<void> call(UserProfile user) async {
    await _firebaseRepository.saveUserProfileToFirestore(user);
  }
}
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class IsUserExitUseCase {
  final FirebaseRepository _firebaseRepository;

  IsUserExitUseCase(this._firebaseRepository);

  Future<bool> call(String login) async {
    return await _firebaseRepository.userExistsByLogin(login);
  }
}
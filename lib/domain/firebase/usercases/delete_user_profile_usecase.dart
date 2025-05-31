import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class DeleteUserProfileUseCase {
  final FirebaseRepository _firebaseRepository;

  DeleteUserProfileUseCase(this._firebaseRepository);

  Future<void> call(int userId) async {
    await _firebaseRepository.deleteUserProfile(userId);
  }
}
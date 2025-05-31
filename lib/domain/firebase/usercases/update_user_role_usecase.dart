import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class UpdateUserRoleUseCase {
  final FirebaseRepository _firebaseRepository;

  UpdateUserRoleUseCase(this._firebaseRepository);

  Future<void> execute(int userId, bool isClubAdmin) async {
    try {
      await _firebaseRepository.updateUserProfile(
        userId: userId,
        isClubAdmin: isClubAdmin,
      );
    } catch (e) {
      throw Exception("Failed to update user role: $e");
    }
  }
}
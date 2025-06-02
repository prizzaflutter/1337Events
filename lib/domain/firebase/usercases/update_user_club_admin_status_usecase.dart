import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class UpdateUserClubAdminStatusUseCase {
  final FirebaseRepository _firebaseRepository;

  UpdateUserClubAdminStatusUseCase(this._firebaseRepository);

  Future<void> call(String userId, bool isAdmin) async {
    try {
      await _firebaseRepository.updateUserClubAdminStatusById(userId, isAdmin);
    } catch (e) {
      // Handle exceptions or errors as needed
      throw Exception('Failed to update user club admin status: $e');
    }
  }
}
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class CheckUserHasAccessUseCase {
  final FirebaseRepository _firebaseRepository;
  CheckUserHasAccessUseCase(this._firebaseRepository);

  Future<bool> call (String login) async {
    try {
      // Assuming the FirebaseRepository has a method to check user access
      return await _firebaseRepository.checkUserHasAccess(login);
    } catch (e) {
      // Handle exceptions or errors as needed
      throw Exception('Failed to check user access: $e');
    }
  }
}
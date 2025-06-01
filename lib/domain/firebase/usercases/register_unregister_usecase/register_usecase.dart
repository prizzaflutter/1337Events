import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class RegisterUseCase{
  final FirebaseRepository _firebaseRepository;

  RegisterUseCase(this._firebaseRepository);

  Future<void> register(String userId, String eventId) async {
    await _firebaseRepository.registerToEvent(userId, eventId);
  }

  Future<void> unregister(String userId, String eventId) async {
    await _firebaseRepository.unregisterFromEvent(userId, eventId);
  }
}
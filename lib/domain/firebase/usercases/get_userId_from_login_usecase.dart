import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class GetUserIdFromLoginUseCase {
   final FirebaseRepository _firebaseRepository;

  GetUserIdFromLoginUseCase(this._firebaseRepository);

  Future<String> call(String login) async{
      return await _firebaseRepository.getIdFromLogin(login);
  }
}
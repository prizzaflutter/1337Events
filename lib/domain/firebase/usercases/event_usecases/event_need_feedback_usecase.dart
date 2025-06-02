
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class EventNeedFeedbackUseCase {
  final FirebaseRepository firebaseRepository;

  EventNeedFeedbackUseCase({
    required this.firebaseRepository,
  });

  Stream<List<NewEventModel>> call ({required String userId}){
    return  firebaseRepository.getEventThatNeedFeedBackStream(userId);
  }

}
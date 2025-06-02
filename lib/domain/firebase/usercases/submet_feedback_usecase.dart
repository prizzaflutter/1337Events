import 'package:the_elsewheres/domain/firebase/model/feedback_model.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class SubmitFeedBackUseCase {
  // This class is responsible for submitting feedback.
  // It will interact with the repository to perform the submission.

  final FirebaseRepository _firebaseRepository;

  SubmitFeedBackUseCase(this._firebaseRepository);

  Future<void> call({required String eventId, required FeedBackModel feedback}) async {
    await _firebaseRepository.submitFeedback(eventId: eventId, feedback: feedback);
  }
}
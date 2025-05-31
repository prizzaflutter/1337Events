import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class DeleteEventUseCase {
  final FirebaseRepository _eventRepository;

  DeleteEventUseCase(this._eventRepository);

  Future<void> call(String eventId) async {
    await _eventRepository.deleteEvent(eventId);
  }
}
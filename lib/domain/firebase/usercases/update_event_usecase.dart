import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class UpdateNewEventUseCase {
  final FirebaseRepository _eventRepository;

  UpdateNewEventUseCase(this._eventRepository);

  Future<void> call(String eventId, NewEventModel event) async {
    await _eventRepository.updateEvent(eventId, event.toDto());
  }
}
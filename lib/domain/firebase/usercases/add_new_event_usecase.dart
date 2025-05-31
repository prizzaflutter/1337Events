import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class AddNewEventUseCase {
  final FirebaseRepository _eventRepository;

  AddNewEventUseCase(this._eventRepository);

  Future<void> call(NewEventModel event) async {
    await _eventRepository.addNewEvent(event);
  }
}
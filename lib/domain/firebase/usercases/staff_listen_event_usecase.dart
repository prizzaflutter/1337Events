import 'package:the_elsewheres/data/firebase/model/new_event_model_dto.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class StaffListenEventUseCase {
  final FirebaseRepository _eventRepository;
  StaffListenEventUseCase(this._eventRepository);
  Stream<List<NewEventModel>> call() {
    Stream<List<NewEventModelDto>> eventDto =   _eventRepository.listenToEvents();
    return eventDto.map((eventList) =>
        eventList.map((event) => event.toDomain()).toList()
    );
  }
}
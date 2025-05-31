import 'package:firebase_core/firebase_core.dart';
import 'package:the_elsewheres/data/firebase/model/new_event_model_dto.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class StudentListenEventUseCase {
  FirebaseRepository _firebaseRepository;
  StudentListenEventUseCase(this._firebaseRepository);
  Stream<List<NewEventModel>> call({required List<String> tags}) {
    Stream<List<NewEventModelDto>> eventDto = _firebaseRepository.listenToEventsByTags(tags);
    return eventDto.map((eventList) =>
        eventList.map((event) => event.toDomain()).toList()
    );
  }
}
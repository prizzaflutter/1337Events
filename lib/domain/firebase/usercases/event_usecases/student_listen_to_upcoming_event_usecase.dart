import 'package:the_elsewheres/data/firebase/model/new_event_model_dto.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class StudentListenToUpComingEventUseCase{
  FirebaseRepository _firebaseRepository;
  StudentListenToUpComingEventUseCase(this._firebaseRepository);
  Stream<List<NewEventModel>> call() {
    Stream<List<NewEventModelDto>> eventDto = _firebaseRepository.listenToUpComingEvents();
    return eventDto.map((eventList) =>
        eventList.map((event) => event.toDomain()).toList()
    );
  }
}
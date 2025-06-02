import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';

class ListenToPendingEventUseCase {
  final FirebaseRepository _firebaseRepository;

  ListenToPendingEventUseCase(this._firebaseRepository);

  Stream<List<NewEventModel>> call() {
    return _firebaseRepository.getPendingEvents();
  }
}
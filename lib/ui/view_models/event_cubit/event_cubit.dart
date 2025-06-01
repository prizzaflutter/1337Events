import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/add_new_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/delete_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/staff_listen_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/student_listen_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/update_event_usecase.dart';

part 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final AddNewEventUseCase _addNewEventUseCase;
  final UpdateNewEventUseCase _updateNewEventUseCase;
  final DeleteEventUseCase _deleteEventUseCase;
  final StaffListenEventUseCase _staffListenEventUseCase;
  final StudentListenEventUseCase _studentListenEventUseCase;
  EventCubit(this._addNewEventUseCase, this._updateNewEventUseCase, this._deleteEventUseCase, this._staffListenEventUseCase, this._studentListenEventUseCase) : super(EventInitial());

  Future<void> addNewEvent(NewEventModel event, {required String filePath}) async {
    emit(AddNewEventLoadingState()) ;
    try {
      await _addNewEventUseCase.call(event, filePath: filePath);
      emit(AddNewEventSuccessState());
    } catch (e) {
      emit(AddNewEventErrorState(e.toString()));
    }
  }
  Future<void> updateEvent(String eventId, NewEventModel event, bool updateImage) async {
    emit(UpdateNewEventLoadingState());
    try {
      await _updateNewEventUseCase.call(eventId, event, updateImage);
      emit(UpdateNewEventSuccessState());
    } catch (e) {
      emit(UpdateNewEventErrorState(e.toString()));
    }
  }
  Future<void> deleteEvent(String eventId) async {
    emit(DeleteEventLoadingState());
    try {
      await _deleteEventUseCase.call(eventId);
      emit(DeleteEventSuccessState());
    } catch (e) {
      emit(DeleteEventErrorState(e.toString()));
    }
  }

  // list to event for staff
  // inside your Cubit or Bloc class

  void listenToEventsForStaff() {
    emit(StaffListenEventLoadingState());

    _staffListenEventUseCase.call().listen(
          (events) {
        emit(StaffListenEventSuccessState(events));
      },
      onError: (error) {
        emit(StaffListenEventErrorState(error.toString()));
      },
    );
  }

  void listenToEventsForStudent(List<String> tags) {
    emit(StudentListenEventLoadingState());

    _studentListenEventUseCase.call(tags: tags).listen(
          (events) {
        emit(StudentListenEventSuccessState(events));
      },
      onError: (error) {
        emit(StudentListenEventErrorState(error.toString()));
      },
    );
  }

}

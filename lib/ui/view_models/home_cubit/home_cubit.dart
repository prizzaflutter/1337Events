import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/usercases/add_new_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/delete_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/update_event_usecase.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AddNewEventUseCase _addNewEventUseCase;
  final UpdateNewEventUseCase _updateNewEventUseCase;
  final DeleteEventUseCase _deleteEventUseCase;
  HomeCubit(this._addNewEventUseCase, this._updateNewEventUseCase, this._deleteEventUseCase) : super(HomeInitial());

  Future<void> addNewEvent(NewEventModel event) async {
    emit(AddNewEventLoadingState()) ;
    try {
      await _addNewEventUseCase.call(event);
      emit(AddNewEventSuccessState());
    } catch (e) {
      emit(AddNewEventErrorState(e.toString()));
    }
  }
  Future<void> updateEvent(String eventId, NewEventModel event) async {
    emit(UpdateNewEventLoadingState());
    try {
      await _updateNewEventUseCase.call(eventId, event);
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
}

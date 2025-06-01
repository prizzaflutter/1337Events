import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/student_listen_to_upcoming_event_usecase.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final  StudentListenToUpComingEventUseCase upComingEventUseCase;
  HomeCubit(this.upComingEventUseCase) : super(HomeInitial());

 void listenToUpComingEvents() {
    emit(StudentListenUpComingLoadingState());
     upComingEventUseCase.call().listen((events){
     emit(StudentListenUpComingSuccessState(events));
     },
     onError: (error){
     emit(StudentListenUpComingErrorState(error));
     });
  }

}

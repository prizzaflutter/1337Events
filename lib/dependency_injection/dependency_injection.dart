import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_elsewheres/data/Oauth/repositories/o_auth_repository_impl.dart';
import 'package:the_elsewheres/data/Oauth/services/o_auth_service.dart';
import 'package:the_elsewheres/data/firebase/repository/firebase_repository_impl.dart';
import 'package:the_elsewheres/data/firebase/service/firebase_service.dart';
import 'package:the_elsewheres/data/local/service/local_service.dart';
import 'package:the_elsewheres/domain/Oauth/repositories/o_auth_repository.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/authenticate_usecase.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/get_user_profile_usecase.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/is_logged_in_usecase.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/logged_out_usecase.dart';
import 'package:the_elsewheres/domain/firebase/repository/FirebaseRepository.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/add_new_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/delete_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/staff_listen_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/student_listen_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/student_listen_to_upcoming_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/update_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/register_unregister_usecase/register_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/save_user_profile_usecase.dart';
import 'package:the_elsewheres/ui/view_models/home_cubit/home_cubit.dart';
import 'package:the_elsewheres/ui/view_models/login_cubit/login_cubit.dart';

GetIt getIt = GetIt.instance;

class GetItService {
  Future<void> setUpLocator() async {
    getIt.registerSingleton<OAuthService>(OAuthService());
    getIt.registerSingleton<OAuthRepository>(
      OAuthRepositoryImpl(getIt<OAuthService>()),
    );

    // local storage
    getIt.registerSingleton<LocalStorageService>(LocalStorageService(await SharedPreferences.getInstance()));

    // firebase storage
    getIt.registerSingleton<FirebaseService>(FirebaseService(getIt<LocalStorageService>(), FirebaseFirestore.instance, FirebaseStorage.instance));
    getIt.registerSingleton<FirebaseRepository>(FirebaseRepositoryImpl(getIt<FirebaseService>()));
    getIt.registerSingleton<SaveUserProfileUseCase>(SaveUserProfileUseCase(getIt<FirebaseRepository>()));



    getIt.registerSingleton<AuthenticateUseCase>(
      AuthenticateUseCase(getIt<OAuthRepository>()),
    );
    getIt.registerSingleton<IsLoggedInUseCase>(
      IsLoggedInUseCase(getIt<OAuthRepository>()),
    );
    getIt.registerSingleton<LogOutUseCase>(
      LogOutUseCase(getIt<OAuthRepository>()),
    );
    getIt.registerSingleton<GetUserProfileUseCase>(
      GetUserProfileUseCase(getIt<OAuthRepository>()),
    );
    getIt.registerSingleton<LoginCubit>(
      LoginCubit(
        getIt<SaveUserProfileUseCase>(),
        getIt<AuthenticateUseCase>(),
        getIt<LogOutUseCase>(),
        getIt<GetUserProfileUseCase>(),
        getIt<IsLoggedInUseCase>(),
      ),
    );

    // event use cases
    getIt.registerSingleton<AddNewEventUseCase>(
      AddNewEventUseCase(getIt<FirebaseRepository>()),
    );
    getIt.registerSingleton<UpdateNewEventUseCase>(
      UpdateNewEventUseCase(getIt<FirebaseRepository>()),
    );
    getIt.registerSingleton<DeleteEventUseCase>(
      DeleteEventUseCase(getIt<FirebaseRepository>()),
    );
    getIt.registerSingleton<StaffListenEventUseCase>(
      StaffListenEventUseCase(getIt<FirebaseRepository>()),
    );
    getIt.registerSingleton<StudentListenEventUseCase>(
      StudentListenEventUseCase(getIt<FirebaseRepository>()),
    );
    getIt.registerSingleton<StudentListenToUpComingEventUseCase>(StudentListenToUpComingEventUseCase(getIt<FirebaseRepository>()));
  getIt.registerSingleton<RegisterUseCase>(RegisterUseCase(
    getIt<FirebaseRepository>(),
  ));
  }

}

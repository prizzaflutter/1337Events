import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_elsewheres/data/authentification/onesignal_notification_services.dart';
import 'package:the_elsewheres/dependency_injection/dependency_injection.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/get_user_profile_usecase.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/is_logged_in_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/add_new_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/delete_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/staff_listen_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/student_listen_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/student_listen_to_upcoming_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/update_event_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/register_unregister_usecase/register_usecase.dart';
import 'package:the_elsewheres/domain/firebase/usercases/save_user_profile_usecase.dart';
import 'package:the_elsewheres/main_page.dart';
import 'package:the_elsewheres/ui/core/theme/theme_cubit/theme_cubit.dart';
import 'package:the_elsewheres/ui/view_models/event_cubit/event_cubit.dart';
import 'package:the_elsewheres/ui/view_models/home_cubit/home_cubit.dart';
import 'package:the_elsewheres/ui/view_models/login_cubit/login_cubit.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'firebase_options.dart';
// Top-level function for handling background notification taps
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // This needs to be a top-level function
  OneSignalNotificationService.notificationTapBackground(notificationResponse);
}


void main() async {
   WidgetsBinding widgetsBinding =  WidgetsFlutterBinding.ensureInitialized();
   await EasyLocalization.ensureInitialized();
   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();
   tz.setLocalLocation(tz.getLocation('Africa/Casablanca'));
   await ScreenUtil.ensureScreenSize();
  await dotenv.load(fileName: ".env");
  await GetItService().setUpLocator();
   final notificationService = OneSignalNotificationService();
   await notificationService.initOneSignalAndLocalNotifications();

   // Check if app was launched from a notification (terminated state)
   await notificationService.checkForInitialNotification();

  // todo : here i will initial the notification service

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create : (context)=> getIt<LoginCubit>()),
      BlocProvider(create: (context)=> ThemeCubit()..loadThemeMode()),
      BlocProvider(create:  (context)=> EventCubit(
          getIt<AddNewEventUseCase>(),
          getIt<UpdateNewEventUseCase>(),
          getIt<DeleteEventUseCase>(),
          getIt<StaffListenEventUseCase>(),
          getIt<StudentListenEventUseCase>(),
      )),
      BlocProvider(create: (context)=>HomeCubit(getIt<StudentListenToUpComingEventUseCase>(), getIt<RegisterUseCase>()))
    ],
    child: EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      startLocale: Locale('en'),
      fallbackLocale: const Locale('en'),
      child: MainPage(),
    )
  ));
}

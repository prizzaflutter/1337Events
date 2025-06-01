import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_elsewheres/dependency_injection/dependency_injection.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/get_user_profile_usecase.dart';
import 'package:the_elsewheres/domain/Oauth/usecases/is_logged_in_usecase.dart';
import 'package:the_elsewheres/main_page.dart';
import 'package:the_elsewheres/ui/core/theme/theme_cubit/theme_cubit.dart';
import 'package:the_elsewheres/ui/view_models/login_cubit/login_cubit.dart';

import 'firebase_options.dart';

void main() async {
   WidgetsBinding widgetsBinding =  WidgetsFlutterBinding.ensureInitialized();
   await EasyLocalization.ensureInitialized();
   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ScreenUtil.ensureScreenSize();
  await dotenv.load(fileName: ".env");
  await GetItService().setUpLocator();

  // todo : here i will initial the notification service

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create : (context)=> getIt<LoginCubit>()),
      BlocProvider(create: (context)=> ThemeCubit()..loadThemeMode()),
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

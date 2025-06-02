import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_elsewheres/networking/network_cubit.dart';
import 'package:the_elsewheres/ui/core/theme/theme_constants.dart';
import 'package:the_elsewheres/ui/core/theme/theme_cubit/theme_cubit.dart';
import 'package:the_elsewheres/ui/go_router/router.dart';
import 'package:the_elsewheres/ui/home/pages/netowk_pages/no_internet_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: '1337Events',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            routerConfig: router,
            builder: (context, child) {
              return BlocBuilder<NetworkCubit, NetworkState>(
                  builder: (context, networkState) {
                if (networkState is NetworkDisconnected) {
                  return NoInternetPage(
                    child: child,
                    onRetry: () {
                      // Optionally refresh the current route after reconnection
                      context.read<NetworkCubit>().checkConnectivity();
                    },
                  );
                }
                return child ?? const SizedBox.shrink();
              });
            },
            themeMode: themeMode,
          );
        },
      ),
    );
  }
}

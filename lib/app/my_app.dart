import 'package:ecuscanqr/app/ui/pages/settings/settings_page.dart';
import 'package:ecuscanqr/app/ui/routes/app_routes.dart';
import 'package:ecuscanqr/app/ui/routes/routes.dart';
import 'package:ecuscanqr/app/ui/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        precacheImage(const AssetImage("assets/images/logo.png"), context);
        return Consumer(
          builder: (_, ref, __) {
            var themeMode = ref
                .watch(settingsProvider.select((theme) => theme.themeMode))
                .themeMode;

            final navigatorKey = ref
                .watch(settingsProvider.select((theme) => theme.navigatorKey))
                .navigatorKey;

            return MaterialApp(
              title: 'EcuScanQR',
              debugShowCheckedModeBanner: false,
              initialRoute: Routes.splash,
              themeMode: themeMode,
              navigatorKey: navigatorKey,
              darkTheme: ThemeData.dark().copyWith(
                textTheme: Theme.of(
                  context,
                ).textTheme.apply(fontFamily: 'Roboto'),
                appBarTheme: const AppBarTheme(color: AppColors.darkColor),
                scaffoldBackgroundColor: AppColors.darkColor,
              ),
              theme: ThemeData.light().copyWith(
                textTheme: Theme.of(
                  context,
                ).textTheme.apply(fontFamily: 'Roboto'),
                appBarTheme: const AppBarTheme(
                  color: AppColors.lightBackground,
                ),
                scaffoldBackgroundColor: Colors.white,
              ),
              routes: routes,
              navigatorObservers: [router.observer],
            );
          },
        );
      },
    );
  }
}

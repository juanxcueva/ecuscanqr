import 'package:ecuscanqr/app/ui/routes/app_routes.dart';
import 'package:ecuscanqr/app/ui/routes/routes.dart';
import 'package:ecuscanqr/app/ui/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        precacheImage(const AssetImage("assets/images/logo.png"), context);
        return MaterialApp(
          title: 'EcuaTresEnRaya',
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.splash,
          darkTheme: ThemeData.dark().copyWith(
            appBarTheme: const AppBarTheme(
              color: AppColors.primaryColor,
            ),
            scaffoldBackgroundColor: AppColors.darkColor,
            textTheme: Theme.of(context).textTheme.apply(
                  fontFamily: 'Rubik Dirt', 
                ),
          ),
          theme: ThemeData.light().copyWith(
            textTheme: Theme.of(context).textTheme.apply(
                  fontFamily: 'Rubik Dirt', 
                ),
            appBarTheme: const AppBarTheme(
              color: AppColors.primaryColor,
            ),
            scaffoldBackgroundColor: Colors.white,
          ),
          routes: routes,
          navigatorObservers: [
            router.observer,
          ],
        );
      },
    );
  }
}

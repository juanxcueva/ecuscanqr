import 'package:flutter/material.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_meedu/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import 'controller/splash_controller.dart';

final splashProvider = SimpleProvider(
  (ref) => SplashController(),
);

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderListener<SplashController>(
        provider: splashProvider,
        onChange: (context, controller) {
          if (controller.navigate) {
            Navigator.pushReplacementNamed(context, splashProvider.read.route);
          }
        },
        builder: (_, controller) {
          return Scaffold(
              body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.gradientMed3,
                    AppColors.gradientMed2,
                  ],
                )),
              ),
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200.r,
                    child: Hero(
                      tag: "logo",
                      child: Image.asset(
                        "assets/images/banner.png",
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * .01,
                  // ),
                  // Text(
                  //   "EcuaTresEnRaya",
                  //   style: TextStyle(
                  //       color: Colors.white,
                  //       fontSize: 24.r,
                  //       wordSpacing: 1,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .03,
                  ),
                  Consumer(builder: (_, ref, __) {
                    final splashController = ref.watch(splashProvider);
                    return Text(splashController.text,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                            wordSpacing: 1,
                            fontWeight: FontWeight.bold));
                  }),
                ],
              ))
            ],
          ));
        });
  }
}

import 'package:ecua_tres_en_raya/app/domain/model/board_setting.dart';
import 'package:ecua_tres_en_raya/app/ui/global_widgets/custom_button_settings_widget.dart';
import 'package:ecua_tres_en_raya/app/ui/global_widgets/modern_button_widget.dart';
import 'package:ecua_tres_en_raya/app/ui/pages/home/controller/home_controller.dart';
import 'package:ecua_tres_en_raya/app/ui/pages/home/widgets/difficulty_widget.dart';
import 'package:ecua_tres_en_raya/app/ui/pages/home/widgets/host_widget.dart';
import 'package:ecua_tres_en_raya/app/ui/pages/local_game/ai_game_page.dart';
import 'package:ecua_tres_en_raya/app/ui/routes/routes.dart';
import 'package:ecua_tres_en_raya/app/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final homeProvider = SimpleProvider(
  (ref) => HomeController(),
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween(begin: -300.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 2;
    _controller.forward();

    // final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 18.h),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200.h,
                        // color: Colors.green,
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(-10, _animation.value),
                            child: Image.asset(
                              "assets/images/banner.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                          // child: Transform.translate(
                          //   offset: Offset(_animation.value * 100, 0),
                          //   child: Image.asset(
                          //     "assets/images/banner.png",
                          //     fit: BoxFit.contain,
                          //   ),
                          // ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Juega con tus amigos o con la computadora",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        shadows: [
                          Shadow(
                            color: Colors.purpleAccent.shade700,
                            blurRadius: 3,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ModernButtonWidget(
                      label: "Juego local IA",
                      icon: Icons.psychology, // ícono de IA
                      onTap: () {
                        displayBottomSheet(context);
                      },
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFFD32F2F)], // rojo
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    ModernButtonWidget(
                      label: "Versus",
                      icon: Icons.people,
                      onTap: () => {
                        boardGameProvider.read.clearBoardAndNewGame(
                          const BoardSetting(
                            3,
                            3,
                            3,
                            aiOpponent: null,
                            opponentStarts: false,
                          ),
                        ),
                        Navigator.pushNamed(context, Routes.aiGame),
                      },
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7E57C2),
                          Color(0xFF5E35B1)
                        ], // púrpura
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    ModernButtonWidget(
                      label: "Multijugador",
                      icon: Icons.public,
                      onTap: () => {
                        displayHostSheet(context),
                      },
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF512DA8),
                          Color(0xFF311B92)
                        ], // azul-morado
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButtonGradientWidget(
                        label: "Acerca de",
                        onTap: () => {
                          Navigator.pushNamed(context, Routes.about),
                        },
                        icon: Icons.info,
                        color: AppColors.primaryColor,
                        colorText: Colors.white,
                        sizeText: 20.sp,
                        sizeBorder: 30,
                        sizeIcon: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future displayBottomSheet(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => const DifficultyWidget(),
    );
  }

  Future displayHostSheet(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) => const HostWidget(),
    );
  }
}

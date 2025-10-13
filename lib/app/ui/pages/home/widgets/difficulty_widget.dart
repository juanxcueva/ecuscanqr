import 'dart:ui';
import 'package:ecua_tres_en_raya/app/domain/model/board_setting.dart';
import 'package:ecua_tres_en_raya/app/domain/model/random_opponent.dart';
import 'package:ecua_tres_en_raya/app/domain/model/smart_opponent.dart';
import 'package:ecua_tres_en_raya/app/domain/model/thinking_opponent.dart';
import 'package:ecua_tres_en_raya/app/ui/global_widgets/difficulty_solid_button.dart';
import 'package:ecua_tres_en_raya/app/ui/pages/local_game/ai_game_page.dart';
import 'package:ecua_tres_en_raya/app/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

// Importa tus nuevos botones
// import '.../difficulty_solid_button.dart';
// import '.../difficulty_neon_button.dart';

class DifficultyWidget extends StatelessWidget {
  const DifficultyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: const Color(0xFF171A1F).withOpacity(0.96),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              boxShadow: const [
                BoxShadow(
                    blurRadius: 24,
                    color: Colors.black54,
                    offset: Offset(0, -6)),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 44,
                    height: 5,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),

                  Text(
                    'Elige el nivel de dificultad',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .2,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ========= FÁCIL =========
                  DifficultySolidButton(
                    // Para look sólido rojo:
                    colorA: const Color(0xFFE53935),
                    colorB: const Color(0xFFD32F2F),

                    // Si mantuviste la API original basada en IconData, mira la sección 3 para `leading`.
                    title: 'Fácil',
                    subtitle: 'Juega y aprende sin presión',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      boardGameProvider.read.clearBoardAndNewGame(
                        const BoardSetting(
                          3,
                          3,
                          3,
                          aiOpponent: RandomOpponent(),
                          opponentStarts: true,
                        ),
                      );
                      Navigator.pushNamed(context, Routes.aiGame);
                    },
                    leading: Lottie.asset(
                      "assets/resources/bot_facil.json",
                      height: 38.h,
                      fit: BoxFit.fitHeight,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ========= MEDIO =========
                  DifficultySolidButton(
                    colorA: const Color(0xFF7E57C2),
                    colorB: const Color(0xFF5E35B1),
                    leading: Lottie.asset(
                      "assets/resources/bot_medio.json",
                      height: 38.h,
                      fit: BoxFit.fitHeight,
                    ),
                    title: 'Medio',
                    subtitle: 'IA balanceada, buenas jugadas',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      boardGameProvider.read.clearBoardAndNewGame(
                        const BoardSetting(
                          3,
                          3,
                          3,
                          aiOpponent: ThinkingOpponent(),
                          opponentStarts: true,
                        ),
                      );
                      Navigator.pushNamed(context, Routes.aiGame);
                    },
                  ),

                  SizedBox(height: 12.h),

                  // ========= DIFÍCIL =========
                  DifficultySolidButton(
                    colorA: const Color(0xFF512DA8),
                    colorB: const Color(0xFF311B92),
                    leading: Lottie.asset(
                      "assets/resources/bot_dificil.json",
                      height: 38.h,
                      fit: BoxFit.fitHeight,
                    ),
                    title: 'Difícil',
                    subtitle: 'Minimax/óptima, sin errores',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      boardGameProvider.read.clearBoardAndNewGame(
                        const BoardSetting(
                          3,
                          3,
                          3,
                          aiOpponent: SmartOpponent(),
                          opponentStarts: true,
                        ),
                      );
                      Navigator.pushNamed(context, Routes.aiGame);
                    },
                  ),

                  SizedBox(height: 8.h),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:ecuscanqr/app/ui/global_widgets/global_badgets.dart';
import 'package:ecuscanqr/app/ui/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_meedu/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'controller/splash_controller.dart';

final splashProvider = SimpleProvider((ref) => SplashController());

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
        final currentTheme = Theme.of(context);
        final isDark = currentTheme.brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: isDark
              ? AppColors.darkColor
              : AppColors.lightBackground,
          body: Stack(
            children: [
              // Fondo animado
              const _AnimatedGradientBackground(),

              // Contenido centrado
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    16.verticalSpace,

                    // Glow + Logo (Hero)
                    const _PulseGlow(
                      child: Hero(tag: "logo", child: LogoBadge()),
                    ),

                    20.verticalSpace,

                    // Texto dinámico desde el controller
                    Consumer(
                      builder: (_, ref, __) {
                        final c = ref.watch(splashProvider);
                        return Text(
                          c.text,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        );
                      },
                    ),

                    18.verticalSpace,

                    // Loader
                    const _LoadingDots(),

                    28.verticalSpace,

                    // Tagline opcional (puedes cambiarlo o quitarlo)
                    Text(
                      "JC • Next-Gen Solutions",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.metallicGrey.withOpacity(.85),
                        letterSpacing: .3,
                      ),
                    ),

                    12.verticalSpace,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Fondo con gradiente animado sutil (no requiere dependencias extra).
class _AnimatedGradientBackground extends StatefulWidget {
  const _AnimatedGradientBackground();

  @override
  State<_AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _t = CurvedAnimation(parent: _ctl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = const [
      AppColors.gradientTop, // #00AFFF
      AppColors.gradientMed, // #0090E0
      AppColors.gradientBottom, // #0066CC
    ];

    return AnimatedBuilder(
      animation: _t,
      builder: (_, __) {
        final begin = Alignment(0.6 - _t.value, -0.8 + _t.value);
        final end = Alignment(-0.6 + _t.value, 0.8 - _t.value);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [
                colors[0].withOpacity(.85),
                colors[1].withOpacity(.75),
                colors[2].withOpacity(.85),
              ],
            ),
          ),
          child: Container(
            // oscurecemos un poco para dar contraste al logo
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkColor.withOpacity(.30),
                  AppColors.darkColor.withOpacity(.55),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Glow pulsante (escala + sombra) alrededor del logo.
class _PulseGlow extends StatefulWidget {
  final Widget child;
  const _PulseGlow({required this.child});

  @override
  State<_PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<_PulseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween(
      begin: 0.98,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) {
        return Transform.scale(
          scale: _scale.value,
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.glowEffect.withOpacity(.45), // #00C9FF
                  blurRadius: 36 + 12 * _scale.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Loader de tres puntos con leve desplazamiento vertical.
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dotSize = 8.0;
    return SizedBox(
      height: 22,
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (_, __) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final t = (_ctl.value + i * .2) % 1.0;
              final dy = math.sin(t * math.pi * 2) * 3.5;
              return Container(
                width: dotSize,
                height: dotSize,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: i == 1
                      ? AppColors.primaryColor
                      : AppColors.secondaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glowEffect.withOpacity(.35),
                      blurRadius: 8,
                      spreadRadius: .5,
                    ),
                  ],
                ),
                transform: Matrix4.translationValues(0, -dy, 0),
              );
            }),
          );
        },
      ),
    );
  }
}

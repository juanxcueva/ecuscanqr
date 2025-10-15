import 'dart:ui';
import 'package:ecuscanqr/app/ui/pages/qr_generator/qr_generator_page.dart';
import 'package:ecuscanqr/app/ui/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;

    // System UI overlay para status bar
    final overlay = SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            // Fondo pastel claro
            const Positioned.fill(child: _SoftLightBackground()),
            // Watermark del logo (usando icono si no tienes imagen)
            Align(
              alignment: Alignment.topRight,
              child: Opacity(
                opacity: .09,
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 180.r,
                  color: const Color(0xFF6461FF),
                ),
              ),
            ),

            // Contenido principal
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    4.verticalSpace,

                    // Mini marca
                    Text.rich(
                      TextSpan(
                        text: "Ecua",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: isDarkTheme ? Colors.white.withOpacity(.8) : AppColors.lightText,
                        ),
                        children: [
                          TextSpan(
                            text: "ScanQR",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    12.verticalSpace,

                    // Título
                    Text(
                      "Define el",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6461FF),
                        letterSpacing: .2,
                      ),
                    ),
                    Text(
                      "Contenido de tu QR",
                      style: TextStyle(
                        fontSize: 30.sp,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: isDarkTheme ? Colors.white.withOpacity(.8) : AppColors.lightText,
                        letterSpacing: .2,
                      ),
                    ),
                    18.verticalSpace,

                    // Tarjetas de opciones con animación
                    ..._qrOptions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;

                      return _StaggeredAnimation(
                        controller: _animationController,
                        index: index,
                        child: _GlassOptionTile(
                          title: option.title,
                          icon: option.icon,
                          gradient: option.gradient,
                          onTap: () => _onOptionTapped(option),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método que se ejecuta al hacer tap en una opción
  void _onOptionTapped(_QrOption option) {
    // Por ahora solo mostramos un SnackBar
    /*
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${option.title} QR selected'),
        backgroundColor: option.gradient.first,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    */

    Navigator.push(
      context,
      MaterialPageRoute(
        // 1. Especificamos la página a la que queremos ir
        builder: (context) => QrGeneratorPage(
          // 2. Pasamos el 'type' de la opción como el parámetro 'qrType'
          qrType: option.type,
        ),
      ),
    );
  }
}

/* ------------------------------ Fondo claro tipo mock ------------------------------ */

class _SoftLightBackground extends StatelessWidget {
  const _SoftLightBackground();

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return Container(
      decoration:  BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkTheme
              ? [
                  Color(0xFF1A1C24), // casi negro con tinte violeta
                  Color(0xFF22252D),
                  Color(0xFF292C34), // toque rosado pálido
                ]
              : [
                  Color(0xFFF3F5FF), // casi blanco con tinte violeta
                  Color(0xFFF7F8FB),
                  Color(0xFFF9F5FF), // toque rosado pálido
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

/* ------------------------------ Animación de entrada escalonada ------------------------------ */

class _StaggeredAnimation extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _StaggeredAnimation({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = 0.05 * index;
    final end = 0.35 + 0.12 * index;

    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        final value = curvedAnimation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/* ------------------------------ Tile glass clara como mock ------------------------------ */

class _GlassOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _GlassOptionTile({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: isDarkTheme ? Colors.grey.withOpacity(.05) : Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18.r),
              child: Container(
                height: 64.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: isDarkTheme ? Colors.grey.withOpacity(.65) : Colors.white.withOpacity(.65),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    colors: isDarkTheme
                        ? [
                            Colors.grey.withOpacity(.72),
                            Colors.grey.withOpacity(.52),
                          ]
                        : [
                            Colors.white.withOpacity(.72),
                            Colors.white.withOpacity(.52),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9FB4FF).withOpacity(.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icono dentro de círculo con glow
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.first.withOpacity(.40),
                            blurRadius: 12,
                            spreadRadius: .5,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: isDarkTheme ? Colors.white.withOpacity(.85) : Colors.white, size: 22.r),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: isDarkTheme ? Colors.white.withOpacity(.85) : Colors.black.withOpacity(.85),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 26.r,
                      color: isDarkTheme ? Colors.white.withOpacity(.55) : Colors.black.withOpacity(.55),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ Modelo de opciones ------------------------------ */

class _QrOption {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final String type;

  _QrOption({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.type,
  });
}

// Lista de opciones de QR
final List<_QrOption> _qrOptions = [
  _QrOption(
    title: "Sitio Web",
    icon: Icons.public_rounded,
    gradient: [const Color(0xFF6CCBFF), const Color(0xFF5D9BFF)],
    type: "website",
  ),
  _QrOption(
    title: "Texto",
    icon: Icons.notes_rounded,
    gradient: [const Color(0xFFFFC08B), const Color(0xFFFF9E8B)],
    type: "text",
  ),
  _QrOption(
    title: "Email",
    icon: Icons.alternate_email_rounded,
    gradient: [const Color(0xFF9AD8FF), const Color(0xFF6CAEFF)],
    type: "email",
  ),
  _QrOption(
    title: "Mensaje de Texto",
    icon: Icons.sms_rounded,
    gradient: [const Color(0xFFFFA7D6), const Color(0xFFFD84BE)],
    type: "sms",
  ),
  _QrOption(
    title: "Red WiFi",
    icon: Icons.wifi_rounded,
    gradient: [const Color(0xFFC7B6FF), const Color(0xFFA895FF)],
    type: "wifi",
  ),
];

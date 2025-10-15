import 'dart:ui';
import 'package:ecuscanqr/app/ui/pages/about/controller/about_controller.dart';
import 'package:ecuscanqr/app/ui/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_meedu/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final aboutProvider = SimpleProvider((ref) => AboutController());

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Fondo pastel igual que HomePage
          const Positioned.fill(child: _SoftLightBackground()),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isDarkTheme
                            ? Colors.white.withOpacity(.1)
                            : Colors.white.withOpacity(.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkTheme
                              ? Colors.white.withOpacity(.2)
                              : Colors.white.withOpacity(.8),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: isDarkTheme
                            ? Colors.white.withOpacity(.8)
                            : const Color(0xFF6461FF),
                        size: 20.r,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  12.verticalSpace,

                  // Header
                  Center(
                    child: Column(
                      children: [
                        // Logo/Avatar
                        Container(
                          width: 100.r,
                          height: 100.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6461FF), Color(0xFF8B87FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6461FF).withOpacity(.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.qr_code_2_rounded,
                            size: 50.r,
                            color: Colors.white,
                          ),
                        ),
                        16.verticalSpace,
                        Text(
                          "EcuaScanQR",
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            color: isDarkTheme
                                ? Colors.white
                                : AppColors.lightText,
                          ),
                        ),
                        8.verticalSpace,
                        Consumer(
                          builder: (_, ref, __) {
                            final version = ref
                                .watch(aboutProvider.select((s) => s.version))
                                .version;
                            return Text(
                              "Version $version",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDarkTheme
                                    ? Colors.white.withOpacity(.8)
                                    : Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  32.verticalSpace,

                  // Developer info
                  _InfoCard(
                    title: "Desarrollado por",
                    items: [
                      _InfoItem(
                        icon: FontAwesomeIcons.code,
                        label: "Developer",
                        value: "juanxcueva",
                        onTap: null,
                      ),
                      _InfoItem(
                        icon: FontAwesomeIcons.locationDot,
                        label: "Ubicación",
                        value: "Cuenca, Ecuador",
                        onTap: null,
                      ),
                    ],
                  ),
                  20.verticalSpace,

                  // Social links
                  _InfoCard(
                    title: "Conecta conmigo",
                    items: [
                      _InfoItem(
                        icon: FontAwesomeIcons.instagram,
                        label: "Instagram",
                        value: "@juanxcueva",
                        onTap: () =>
                            _openUrl('https://www.instagram.com/juanxcueva'),
                      ),
                      _InfoItem(
                        icon: FontAwesomeIcons.github,
                        label: "GitHub",
                        value: "github.com/juanxcueva",
                        onTap: () => _openUrl('https://github.com/juanxcueva'),
                      ),
                    ],
                  ),
                  20.verticalSpace,

                  // Buy me a coffee button
                  _CoffeeButton(
                    onTap: () =>
                        _openUrl('https://www.buymeacoffee.com/juanxcueva'),
                  ),
                  24.verticalSpace,

                  // App description
                  _InfoCard(
                    title: "Acerca de la App",
                    items: [
                      _DescriptionItem(
                        text:
                            "EcuaScanQR es una app muy poderosa y fácil de usar, sirve "
                            "para generar y escanear códigos QR. Crea códigos QR "
                            "para sitios web, textos, correos electrónicos, SMS y "
                            "redes WiFi. Escanea cualquier código QR instantáneamente "
                            "y gestiona tu historial.",
                      ),
                    ],
                  ),
                  24.verticalSpace,

                  // Made with love
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Made with",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDarkTheme
                                ? Colors.white.withOpacity(.8)
                                : Colors.grey.shade600,
                          ),
                        ),
                        6.horizontalSpace,
                        Icon(
                          Icons.favorite,
                          size: 14.r,
                          color: Colors.red.shade400,
                        ),
                        6.horizontalSpace,
                        Text(
                          "in Ecuador",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDarkTheme
                                ? Colors.white.withOpacity(.8)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ Background ------------------------------ */

class _SoftLightBackground extends StatelessWidget {
  const _SoftLightBackground();

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDarkTheme ? Color(0xFF1F2129) : Color(0xFFF3F5FF),
            isDarkTheme ? Color(0xFF262833) : Color(0xFFF7F8FB),
            isDarkTheme ? Color(0xFF303340) : Color(0xFFF9F5FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

/* ------------------------------ Info Card ------------------------------ */

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDarkTheme
                  ? Colors.white.withOpacity(.8)
                  : Colors.black87,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? Colors.white.withOpacity(.1)
                    : Colors.white.withOpacity(.7),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDarkTheme
                      ? Colors.white.withOpacity(.2)
                      : Colors.white.withOpacity(.8),
                ),
              ),
              child: Column(children: items),
            ),
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ Info Item ------------------------------ */

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDarkTheme
                    ? Colors.white.withOpacity(.2)
                    : Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isDarkTheme
                      ? Colors.white.withOpacity(.2)
                      : const Color(0xFF6461FF).withOpacity(.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: FaIcon(
                  icon,
                  color: isDarkTheme
                      ? Colors.white.withOpacity(.8)
                      : const Color(0xFF6461FF),
                  size: 20.r,
                ),
              ),
              16.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDarkTheme
                            ? Colors.white.withOpacity(.8)
                            : Colors.grey.shade600,
                      ),
                    ),
                    4.verticalSpace,
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: isDarkTheme
                            ? Colors.white.withOpacity(.8)
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.r,
                  color: isDarkTheme
                      ? Colors.white.withOpacity(.8)
                      : Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ Description Item ------------------------------ */

class _DescriptionItem extends StatelessWidget {
  final String text;

  const _DescriptionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.6,
          color: isDarkTheme
              ? Colors.white.withOpacity(.8)
              : Colors.grey.shade700,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

/* ------------------------------ Coffee Button ------------------------------ */

class _CoffeeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CoffeeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFDD00), Color(0xFFFFA000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFDD00).withOpacity(.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.mugHot, color: Colors.white, size: 24.r),
            12.horizontalSpace,
            Text(
              "Buy me a coffee",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

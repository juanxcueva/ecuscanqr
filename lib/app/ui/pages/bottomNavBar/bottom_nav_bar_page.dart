import 'dart:ui';
import 'package:ecuscanqr/app/ui/pages/home/controller/home_controller.dart';
import 'package:ecuscanqr/app/ui/pages/home/home_page.dart';
import 'package:ecuscanqr/app/ui/pages/history/history_page.dart';
import 'package:ecuscanqr/app/ui/pages/settings/settings_page.dart';
import 'package:ecuscanqr/app/ui/pages/scan/scan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_meedu/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Provider con autoDispose: false para mantener el estado
final homeProvider = SimpleProvider(
  (ref) => HomeController(),
  autoDispose: false,
);

class BottomNavBarPage extends StatelessWidget {
  const BottomNavBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final overlay = SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    return Consumer(
      builder: (_, ref, __) {
        final controller = ref.watch(homeProvider);
        
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            body: Stack(
              children: [
                // Fondo pastel
                const Positioned.fill(child: _SoftLightBackground()),

                // Contenido principal con IndexedStack (NO PageView)
                SafeArea(
                  child: Stack(
                    children: [
                      // IndexedStack mantiene el estado de todas las páginas
                      Padding(
                        padding: EdgeInsets.only(bottom: 80.h), // Espacio para el navbar
                        child: IndexedStack(
                          index: controller.currentPageIndex,
                          children: const [
                            HomePage(), // 0: Create QR
                            HistoryPage(), // 1: History
                            SettingsPage(), // 2: Settings
                          ],
                        ),
                      ),

                      // Bottom navigation bar
                      Positioned(
                        bottom: 16.h,
                        left: 16.w,
                        right: 16.w,
                        child: _BottomNavBar(
                          currentIndex: controller.currentPageIndex,
                          onTap: (index) {
                            if (index == 1) {
                              // Si toca el botón central (Scanner), abrir página completa
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ScanPage(),
                                ),
                              );
                            } else {
                              // Para otras pestañas, cambiar normalmente
                              controller.changePage(index > 1 ? index - 1 : index);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ------------------------------ Fondo claro ------------------------------ */

class _SoftLightBackground extends StatelessWidget {
  const _SoftLightBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF3F5FF),
            Color(0xFFF7F8FB),
            Color(0xFFF9F5FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

/* ------------------------------ Bottom Navigation Bar ------------------------------ */

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 72.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.92),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withOpacity(.75)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9FB4FF).withOpacity(.26),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Create QR
              _NavItem(
                icon: Icons.qr_code_2_rounded,
                label: "Crear",
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              
              // Scanner (botón central especial)
              _ScanButton(onTap: () => onTap(1)),
              
              // History
              _NavItem(
                icon: Icons.history_rounded,
                label: "Historial",
                selected: currentIndex == 1,
                onTap: () => onTap(2),
              ),
              
              // Settings
              _NavItem(
                icon: Icons.settings_rounded,
                label: "Configuración",
                selected: currentIndex == 2,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ Botón de Scanner (especial) ------------------------------ */

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 56.r,
        height: 56.r,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6461FF), Color(0xFF8B87FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6461FF).withOpacity(.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 28.r,
        ),
      ),
    );
  }
}

/* ------------------------------ Nav Item normal ------------------------------ */

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color active = const Color(0xFF5D6BFF);
    final Color inactive = const Color(0xFF9AA4B2);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22.r, color: selected ? active : inactive),
            4.verticalSpace,
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? active : inactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
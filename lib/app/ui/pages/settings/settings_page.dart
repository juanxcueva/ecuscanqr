import 'dart:ui';
import 'package:ecuscanqr/app/data/resources/local/hive_storage_service.dart';
import 'package:ecuscanqr/app/ui/pages/about/about_page.dart';
import 'package:ecuscanqr/app/ui/pages/settings/controller/settings_controller.dart';
import 'package:ecuscanqr/app/ui/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_meedu/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

final settingsProvider = SimpleProvider(
  (ref) => SettingsController(),
  autoDispose: false,
);

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        final controller = ref.watch(settingsProvider);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Configuración",
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.lightText,
                ),
              ),
              8.verticalSpace,
              Text(
                "Personaliza tu experiencia",   
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              24.verticalSpace,

              // Estadísticas
              _StatisticsCard(),
              20.verticalSpace,

              // Appearance Section
              _SectionHeader(title: "Apariencia"),
              12.verticalSpace,
              _SettingTile(
                icon: Icons.dark_mode_outlined,
                title: "Modo Oscuro",
                subtitle: "Cambia entre tema claro y oscuro",
                trailing: Switch(
                  value: controller.isDarkMode,
                  onChanged: controller.toggleDarkMode,
                  activeColor: const Color(0xFF6461FF),
                ),
              ),
              12.verticalSpace,

              // Data & Storage
              _SectionHeader(title: "Datos y Almacenamiento"),
              12.verticalSpace,
              _SettingTile(
                icon: Icons.download_outlined,
                title: "Exportar Historial",
                subtitle: "Exportar todos los códigos QR como JSON",
                onTap: () => _exportHistory(context, controller),
              ),
              _SettingTile(
                icon: Icons.upload_outlined,
                title: "Importar Historial",
                subtitle: "Importar códigos QR desde un archivo JSON",
                onTap: () => _showComingSoon(context, "Import History"),
              ),
              _SettingTile(
                icon: Icons.delete_sweep_outlined,
                title: "Limpiar Todo el Historial",
                subtitle: "Eliminar todos los códigos QR permanentemente",
                titleColor: Colors.red,
                onTap: () => _confirmClearAll(context, controller),
              ),
              12.verticalSpace,

              // Scanner Settings
              _SectionHeader(title: "Escáner"),
              12.verticalSpace,
              _SettingTile(
                icon: Icons.vibration,
                title: " Vibración al Detectar",
                subtitle: " Vibración cuando se detecta un código QR",
                trailing: Switch(
                  value: controller.vibrateOnScan,
                  onChanged: controller.toggleVibration,
                  activeColor: const Color(0xFF6461FF),
                ),
              ),
              _SettingTile(
                icon: Icons.volume_up_outlined,
                title: " Sonido al Detectar",
                subtitle: "Reproducir sonido cuando se detecta un código QR",
                trailing: Switch(
                  value: controller.soundOnScan,
                  onChanged: controller.toggleSound,
                  activeColor: const Color(0xFF6461FF),
                ),
              ),
              12.verticalSpace,

              // About & Help
              _SectionHeader(title: "Acerca y Ayuda"),
              12.verticalSpace,
              _SettingTile(
                icon: Icons.share_outlined,
                title: "Compartir Aplicación",
                subtitle: "Compartir EcuaScanQR con amigos",
                onTap: () => _shareApp(context),
              ),
              _SettingTile(
                icon: Icons.star_outline,
                title: "Calificar Aplicación",
                subtitle: "Califica la aplicación en la Play Store",
                onTap: () => _showComingSoon(context, "Rate Us"),
              ),
              _SettingTile(
                icon: Icons.bug_report_outlined,
                title: "Reportar Error",
                subtitle: "Ayuda a mejorar la aplicación",
                onTap: () => _showComingSoon(context, "Report Bug"),
              ),
              _SettingTile(
                icon: Icons.info_outline,
                title: "Acerca de",
                subtitle: "Versión, licencias y más",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                ),
              ),
              24.verticalSpace,

              // Version info
              Center(
                child: Column(
                  children: [
                    Text(
                      "EcuaScanQR",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    4.verticalSpace,
                    Text(
                      "Versión 1.0.0",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportHistory(BuildContext context, SettingsController controller) {
    final stats = HiveStorageService.getStatistics();
    final total = stats['total'] ?? 0;

    if (total == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Text("No hay códigos QR para exportar"),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    controller.exportHistory(context);
  }

  void _confirmClearAll(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28.r),
            12.horizontalSpace,
            const Text('Eliminar Todos los Datos?'),
          ],
        ),
        content: const Text(
          'Esto eliminará permanentemente todos sus códigos QR. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              controller.clearAllData(context);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar Todos'),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    Share.share(
      'Descubre EcuaScanQR - La mejor aplicación para generar y escanear códigos QR!\n\n'
      'Descárgalo ahora: [App Store Link]',
      subject: 'Intenta EcuaScanQR!',
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature pronto disponible!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/* ------------------------------ Statistics Card ------------------------------ */

class _StatisticsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = HiveStorageService.getStatistics();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6461FF).withOpacity(.15),
                const Color(0xFF8B87FF).withOpacity(.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    color: const Color(0xFF6461FF),
                    size: 24.r,
                  ),
                  12.horizontalSpace,
                  Text(
                    "Estadísticas de Uso",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightText,
                    ),
                  ),
                ],
              ),
              16.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: "Total",
                    value: stats['total'] ?? 0,
                    icon: Icons.qr_code_2,
                    color: const Color(0xFF6461FF),
                  ),
                  _StatItem(
                    label: "Generados",
                    value: stats['generated'] ?? 0,
                    icon: Icons.add_circle_outline,
                    color: Colors.green,
                  ),
                  _StatItem(
                    label: "Escaneados",
                    value: stats['scanned'] ?? 0,
                    icon: Icons.qr_code_scanner,
                    color: Colors.blue,
                  ),
                  _StatItem(
                    label: "Favoritos",
                    value: stats['favorites'] ?? 0,
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: color.withOpacity(.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24.r),
        ),
        8.verticalSpace,
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.lightText,
          ),
        ),
        2.verticalSpace,
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ Section Header ------------------------------ */

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.lightText,
        ),
      ),
    );
  }
}

/* ------------------------------ Setting Tile ------------------------------ */

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? titleColor;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.white.withOpacity(.6),
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white.withOpacity(.8)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: titleColor?.withOpacity(.1) ??
                            const Color(0xFF6461FF).withOpacity(.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        icon,
                        color: titleColor ?? const Color(0xFF6461FF),
                        size: 22.r,
                      ),
                    ),
                    16.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: titleColor ?? Colors.black87,
                            ),
                          ),
                          4.verticalSpace,
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null)
                      trailing!
                    else if (onTap != null)
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                        size: 24.r,
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
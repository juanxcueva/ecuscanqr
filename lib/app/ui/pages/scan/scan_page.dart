import 'dart:ui';
import 'package:ecuscanqr/app/ui/pages/scan/controller/scan_controller.dart';
import 'package:ecuscanqr/app/ui/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_meedu/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

final scanProvider = SimpleProvider<ScanController>((ref) {
  return ScanController();
});

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        final controller = ref.watch(scanProvider);

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Scanner o mensaje de permiso
              if (controller.hasPermission && controller.scannerController != null)
                _ScannerView(controller: controller)
              else
                _PermissionDeniedView(controller: controller),

              // Overlay con controles
              _ScannerOverlay(controller: controller),

              // Resultado del escaneo
              if (controller.lastScannedCode != null)
                _ScannedResultSheet(
                  code: controller.lastScannedCode!,
                  onClose: controller.resetScan,
                ),
            ],
          ),
        );
      },
    );
  }
}

/* ------------------------------ Vista del Scanner ------------------------------ */

class _ScannerView extends StatelessWidget {
  final ScanController controller;

  const _ScannerView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: controller.scannerController,
      onDetect: controller.onDetect,
      errorBuilder: (context, error, child) {
        return Center(
          child: Text(
            'Error: ${error.errorDetails?.message ?? 'Error desconocido'}',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}

/* ------------------------------ Vista sin permisos ------------------------------ */

class _PermissionDeniedView extends StatelessWidget {
  final ScanController controller;

  const _PermissionDeniedView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 100.r,
                color: Colors.white.withOpacity(.5),
              ),
              24.verticalSpace,
              Text(
                'Permiso de cámara requerido',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              12.verticalSpace,
              Text(
                'Por favor, concede acceso a la cámara para escanear códigos QR',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(.7),
                ),
                textAlign: TextAlign.center,
              ),
              32.verticalSpace,
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.isInitializing 
                      ? null 
                      : () async {
                          final granted = await controller.requestPermission();
                          if (!granted && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Permiso de cámara denegado. Por favor, habilítalo en Ajustes.',
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                action: SnackBarAction(
                                  label: 'Abrir Ajustes',
                                  textColor: Colors.white,
                                  onPressed: () => openAppSettings(),
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6461FF),
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: controller.isInitializing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            12.horizontalSpace,
                            Text(
                              'Inicializando...',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Conceder Permiso',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ Overlay del Scanner ------------------------------ */

class _ScannerOverlay extends StatelessWidget {
  final ScanController controller;

  const _ScannerOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header con título y botón de cerrar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20.r,
                    ),
                  ),
                ),
                Text(
                  'Escanear Código QR',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 48), // Para centrar el título
              ],
            ),
          ),

          const Spacer(),

          // Área de escaneo con marco
          _ScanFrame(),

          const Spacer(),

          // Controles inferiores
          if (controller.hasPermission) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.6),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ControlButton(
                          icon: controller.isFlashOn
                              ? Icons.flash_on
                              : Icons.flash_off,
                          label: 'Flash',
                          onTap: controller.toggleFlash,
                        ),
                        _ControlButton(
                          icon: Icons.flip_camera_ios,
                          label: 'Cambiar Cámara',
                          onTap: controller.switchCamera,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            16.verticalSpace,
          ],
        ],
      ),
    );
  }
}

/* ------------------------------ Marco de escaneo ------------------------------ */

class _ScanFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280.w,
      height: 280.w,
      child: Stack(
        children: [
          // Esquinas del marco
          ..._buildCorners(),
          
          // Línea de escaneo animada
          _AnimatedScanLine(),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const cornerSize = 40.0;
    const cornerThickness = 4.0;
    const color = Color(0xFF6461FF);

    return [
      // Esquina superior izquierda
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: cornerThickness),
              left: BorderSide(color: color, width: cornerThickness),
            ),
          ),
        ),
      ),
      // Esquina superior derecha
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: cornerThickness),
              right: BorderSide(color: color, width: cornerThickness),
            ),
          ),
        ),
      ),
      // Esquina inferior izquierda
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: cornerThickness),
              left: BorderSide(color: color, width: cornerThickness),
            ),
          ),
        ),
      ),
      // Esquina inferior derecha
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: cornerThickness),
              right: BorderSide(color: color, width: cornerThickness),
            ),
          ),
        ),
      ),
    ];
  }
}

/* ------------------------------ Línea de escaneo animada ------------------------------ */

class _AnimatedScanLine extends StatefulWidget {
  @override
  State<_AnimatedScanLine> createState() => _AnimatedScanLineState();
}

class _AnimatedScanLineState extends State<_AnimatedScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: _animation.value * 250.w,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF6461FF).withOpacity(.8),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6461FF).withOpacity(.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ------------------------------ Botón de control ------------------------------ */

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28.r),
          4.verticalSpace,
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ Sheet de resultado ------------------------------ */

class _ScannedResultSheet extends StatelessWidget {
  final String code;
  final VoidCallback onClose;

  const _ScannedResultSheet({
    required this.code,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              16.verticalSpace,

              // Success icon
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48.r,
                ),
              ),
              16.verticalSpace,

              Text(
                'Código QR Escaneado!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightText,
                ),
              ),
              12.verticalSpace,

              // Código escaneado
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: SelectableText(
                  code,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              24.verticalSpace,

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                      label: const Text('Cerrar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAction(code),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Abrir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6461FF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(String code) async {
    // Si es una URL, abrirla
    if (code.startsWith('http://') || code.startsWith('https://')) {
      final uri = Uri.parse(code);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (code.startsWith('mailto:')) {
      final uri = Uri.parse(code);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else if (code.startsWith('tel:')) {
      final uri = Uri.parse(code);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else if (code.startsWith('SMSTO:')) {
      // Manejar SMS
      final parts = code.substring(6).split(':');
      if (parts.length >= 2) {
        final phone = parts[0];
        final uri = Uri.parse('sms:$phone');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      }
    }
    // Agregar más tipos según necesites
  }
}
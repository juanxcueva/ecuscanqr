import 'dart:ui';
import 'package:ecuscanqr/app/ui/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:ecuscanqr/app/ui/pages/qr_generator/controller/qr_generator_controller.dart';

final qrGeneratorProvider = SimpleProvider<QrGeneratorController>((ref) {
  return QrGeneratorController();
});

class QrGeneratorPage extends StatelessWidget {
  final String qrType;

  const QrGeneratorPage({super.key, required this.qrType});

  @override
  Widget build(BuildContext context) {
   
     final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return Consumer(
      builder: (_, ref, __) {
        final controller = ref.watch(qrGeneratorProvider)..setQrType(qrType);

        return GestureDetector(
          // Cerrar teclado al tocar fuera
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: isDarkTheme ? Colors.grey.withOpacity(.12) : const Color(0xFFF3F5FF),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6461FF)),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);
                },
              ),
              title: Text(
                'Crear ${_getTypeTitle(qrType)} QR',
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : AppColors.lightText,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
              ),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              // Agregar padding extra para el teclado
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  // Preview del QR
                  _QrPreviewCard(
                    data: controller.generatedData,
                    isValid: controller.isValid,
                  ),
                  24.verticalSpace,

                  // Formulario según el tipo
                  _buildForm(qrType, controller),

                  24.verticalSpace,

                  // Botón de generar
                  _GenerateButton(
                    onPressed: controller.isValid
                        ? () {
                            FocusScope.of(context).unfocus();
                            controller.saveQr(context);
                          }
                        : null,
                    isValid: controller.isValid,
                  ),
                  
                  // Espacio extra para el teclado
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 40.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(String type, QrGeneratorController controller) {
    switch (type) {
      case 'website':
        return _WebsiteForm(controller: controller);
      case 'text':
        return _TextForm(controller: controller);
      case 'email':
        return _EmailForm(controller: controller);
      case 'sms':
        return _SmsForm(controller: controller);
      case 'wifi':
        return _WifiForm(controller: controller);
      default:
        return const SizedBox();
    }
  }

  String _getTypeTitle(String type) {
    switch (type) {
      case 'website':
        return 'Website';
      case 'text':
        return 'Text';
      case 'email':
        return 'Email';
      case 'sms':
        return 'SMS';
      case 'wifi':
        return 'WiFi';
      default:
        return 'QR';
    }
  }
}

/* ------------------------------ QR Preview Card ------------------------------ */

class _QrPreviewCard extends StatelessWidget {
  final String data;
  final bool isValid;

  const _QrPreviewCard({
    required this.data,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: isDarkTheme ? Colors.grey.withOpacity(.9) : Colors.white.withOpacity(.85),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: isDarkTheme ? Colors.grey.withOpacity(.9) : Colors.white.withOpacity(.9)),
            boxShadow: [
              BoxShadow(
                color: isDarkTheme ? Colors.grey.withOpacity(.2) : const Color(0xFF9FB4FF).withOpacity(.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDarkTheme ? Colors.black.withOpacity(.85) : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: data.isEmpty
                    ? _EmptyQrPlaceholder()
                    : QrImageView(
                        data: data,
                        version: QrVersions.auto,
                        size: 220.w,
                        backgroundColor: isDarkTheme ? Colors.white.withOpacity(.85) : Colors.white,
                        errorStateBuilder: (ctx, err) => _ErrorQrPlaceholder(),
                      ),
              ),
              if (data.isNotEmpty) ...[
                16.verticalSpace,
                Text(
                  isValid ? 'Código QR listo!' : 'Datos inválidos',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isValid ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyQrPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return SizedBox(
      width: 220.w,
      height: 220.w,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2_rounded,
              size: 80.r,
              color: isDarkTheme ? Colors.grey.shade300.withOpacity(.8) : Colors.grey.shade300,
            ),
            12.verticalSpace,
            Text(
              'LLena el formulario para generar',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDarkTheme ? Colors.grey.shade400.withOpacity(.8) : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorQrPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220.w,
      height: 220.w,
      child: Center(
        child: Icon(
          Icons.error_outline,
          size: 60.r,
          color: Colors.red.shade300,
        ),
      ),
    );
  }
}

/* ------------------------------ Formularios por tipo ------------------------------ */

class _WebsiteForm extends StatelessWidget {
  final QrGeneratorController controller;

  const _WebsiteForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _GlassFormCard(
      child: Column(
        children: [
          _CustomTextField(
            label: 'Sitio Web URL',
            hint: 'https://example.com',
            icon: Icons.link,
            onChanged: (value) => controller.updateField('url', value),
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }
}

class _TextForm extends StatelessWidget {
  final QrGeneratorController controller;

  const _TextForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _GlassFormCard(
      child: Column(
        children: [
          _CustomTextField(
            label: 'Contenido de texto',
            hint: 'Ingresa tu texto aquí',
            icon: Icons.text_fields,
            onChanged: (value) => controller.updateField('text', value),
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}

class _EmailForm extends StatelessWidget {
  final QrGeneratorController controller;

  const _EmailForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _GlassFormCard(
      child: Column(
        children: [
          _CustomTextField(
            label: 'Dirección de correo electrónico',
            hint: 'example@email.com',
            icon: Icons.email,
            onChanged: (value) => controller.updateField('email', value),
            keyboardType: TextInputType.emailAddress,
          ),
          16.verticalSpace,
          _CustomTextField(
            label: 'Asunto (Opcional)',
            hint: 'Asunto del correo',
            icon: Icons.subject,
            onChanged: (value) => controller.updateField('subject', value),
          ),
          16.verticalSpace,
          _CustomTextField(
            label: 'Mensaje (Opcional)',
            hint: 'Cuerpo del mensaje',
            icon: Icons.message,
            onChanged: (value) => controller.updateField('body', value),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _SmsForm extends StatelessWidget {
  final QrGeneratorController controller;

  const _SmsForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _GlassFormCard(
      child: Column(
        children: [
          _CustomTextField(
            label: 'Número de teléfono',
            hint: '+593 999 999 999',
            icon: Icons.phone,
            onChanged: (value) => controller.updateField('phone', value),
            keyboardType: TextInputType.phone,
          ),
          16.verticalSpace,
          _CustomTextField(
            label: 'Mensaje (Opcional)',
            hint: 'Mensaje SMS',
            icon: Icons.message,
            onChanged: (value) => controller.updateField('message', value),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _WifiForm extends StatelessWidget {
  final QrGeneratorController controller;

  const _WifiForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _GlassFormCard(
      child: Column(
        children: [
          _CustomTextField(
            label: 'Nombre de la red (SSID)',
            hint: 'Nombre de la red WiFi',
            icon: Icons.wifi,
            onChanged: (value) => controller.updateField('ssid', value),
          ),
          16.verticalSpace,
          _CustomTextField(
            label: 'Contraseña (Opcional)',
            hint: 'Contraseña WiFi',
            icon: Icons.lock,
            onChanged: (value) => controller.updateField('password', value),
            obscureText: true,
          ),
          16.verticalSpace,
          _SecurityDropdown(
            onChanged: (value) => controller.updateField('security', value),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ Widgets comunes ------------------------------ */

class _GlassFormCard extends StatelessWidget {
  final Widget child;

  const _GlassFormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: isDarkTheme ? Colors.grey.withOpacity(.8) : Colors.white.withOpacity(.7),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: isDarkTheme ? Colors.grey.withOpacity(.8) : Colors.white.withOpacity(.8)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;

  const _CustomTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDarkTheme = currentTheme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.lightText,
          ),
        ),
        8.verticalSpace,
        TextField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF6461FF)),
            filled: true,
            fillColor: isDarkTheme ? Colors.grey.withOpacity(.8) : Colors.white.withOpacity(.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF6461FF), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityDropdown extends StatefulWidget {
  final Function(String) onChanged;

  const _SecurityDropdown({required this.onChanged});

  @override
  State<_SecurityDropdown> createState() => _SecurityDropdownState();
}

class _SecurityDropdownState extends State<_SecurityDropdown> {
  String _selected = 'WPA';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Type',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.lightText,
          ),
        ),
        8.verticalSpace,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.9),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButton<String>(
            value: _selected,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6461FF)),
            items: ['WPA', 'WEP', 'nopass'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selected = value!);
              widget.onChanged(value!);
            },
          ),
        ),
      ],
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isValid;

  const _GenerateButton({
    required this.onPressed,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? const Color(0xFF6461FF) : Colors.grey,
          foregroundColor: Colors.white,
          elevation: isValid ? 8 : 0,
          shadowColor: const Color(0xFF6461FF).withOpacity(.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Text(
          'Guardar Código QR',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
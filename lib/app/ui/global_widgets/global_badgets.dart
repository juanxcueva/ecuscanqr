import 'package:ecuscanqr/app/ui/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Contenedor del logo con forma y borde sutil.
class LogoBadge extends StatelessWidget {
  const LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.r,
      height: 180.r,
      decoration: BoxDecoration(
        color: AppColors.darkContainerColor.withOpacity(.75),
        borderRadius: BorderRadius.circular(36.r),
        border: Border.all(color: AppColors.metallicGrey.withOpacity(.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withOpacity(.6),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.all(20.r),
      child: Image.asset(
        "assets/images/logo.png", // tu PNG 512x512 con fondo
        fit: BoxFit.contain,
      ),
    );
  }
}
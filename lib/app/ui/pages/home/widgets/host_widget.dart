import 'dart:ui';
import 'package:ecua_tres_en_raya/app/ui/pages/find_devices/find_devices_page.dart';
import 'package:ecua_tres_en_raya/app/ui/pages/home/widgets/host_action_button.dart';
import 'package:ecua_tres_en_raya/app/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HostWidget extends StatelessWidget {
  const HostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          decoration: BoxDecoration(
            color: const Color(0xFF171A1F).withOpacity(0.96),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: const [
              BoxShadow(blurRadius: 24, color: Colors.black54, offset: Offset(0, -6)),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                Container(
                  width: 44, height: 5,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),

                Text(
                  'Elige una opción',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18.sp,
                    letterSpacing: .2,
                  ),
                ),
                SizedBox(height: 16.h),

                HostActionButton(
                  leading: const FaIcon(FontAwesomeIcons.userAstronaut, color: Colors.white),
                  title: 'Ser anfitrión',
                  subtitle: 'Crea la sala para jugar con tus amigos',
                  glowColor: const Color(0xFF1E88E5),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pushNamed(
                      context,
                      Routes.findDevices,
                      arguments: const FindDevicesArgs(isHost: true),
                    );
                    findDeviceProvider.read.isAnfitrion = true;
                  },
                ),

                SizedBox(height: 12.h),

                HostActionButton(
                  leading: const FaIcon(FontAwesomeIcons.userGroup, color: Colors.white),
                  title: 'Ser invitado',
                  subtitle: 'Únete a la sala de un amigo',
                  glowColor: const Color(0xFF42A5F5),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pushNamed(
                      context,
                      Routes.findDevices,
                      arguments: const FindDevicesArgs(isHost: false),
                    );
                    findDeviceProvider.read.isAnfitrion = false;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

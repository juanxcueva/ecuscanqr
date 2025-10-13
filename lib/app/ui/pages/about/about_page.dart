// about_page.dart
import 'package:ecua_tres_en_raya/app/ui/global_widgets/game_header_widget.dart';
import 'package:ecua_tres_en_raya/app/ui/pages/about/controller/about_controller.dart';
import 'package:ecua_tres_en_raya/app/ui/pages/about/widgets/about_tile_widget.dart';
import 'package:ecua_tres_en_raya/app/ui/pages/about/widgets/cofee_button.dart';
import 'package:ecua_tres_en_raya/app/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_meedu/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final aboutProvider = SimpleProvider(
  (ref) => AboutController(),
);

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header unificado
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: GameHeader(
                  title: 'Acerca de',
                  turnText: '',
                  turnColor: Colors.transparent,
                  showTurnChip: false,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Column(
                  children: [
                    const AboutInfoTile(
                      title: 'Desarrollado por',
                      subtitle: 'juanxcueva',
                      icon: FontAwesomeIcons.dev,
                      interactive: false,
                    ),
                    SizedBox(height: 12.h),

                    Consumer(builder: (_, ref, __) {
                      final version = ref
                          .watch(aboutProvider.select((s) => s.version))
                          .version;
                      return AboutInfoTile(
                        title: 'Versión',
                        subtitle: version,
                        icon: FontAwesomeIcons.codeBranch,
                        interactive: false,
                      );
                    }),
                    SizedBox(height: 12.h),

                    AboutInfoTile(
                      title: 'Instagram',
                      subtitle: '@juanxcueva',
                      icon: FontAwesomeIcons.instagram,
                      onTap: () =>
                          _openUrl('https://www.instagram.com/juanxcueva'),
                    ),
                    SizedBox(height: 12.h),

                    AboutInfoTile(
                      title: 'Sitio web',
                      subtitle: 'github.com/juanxcueva',
                      icon: FontAwesomeIcons.globe,
                      onTap: () => _openUrl('https://github.com/juanxcueva'),
                    ),
                    SizedBox(height: 12.h),

                    const AboutInfoTile(
                      title: 'Dirección',
                      subtitle: 'Cuenca, Ecuador',
                      icon: FontAwesomeIcons.locationDot,
                      interactive: false,
                    ),
                    SizedBox(height: 20.h),

                    // CTA destacado
                    CoffeeButton(
                      onTap: () =>
                          _openUrl('https://www.buymeacoffee.com/juanxcueva'),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

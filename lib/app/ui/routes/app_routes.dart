import 'package:ecuscanqr/app/ui/pages/about/about_page.dart';
import 'package:ecuscanqr/app/ui/pages/bottomNavBar/bottom_nav_bar_page.dart';
import 'package:ecuscanqr/app/ui/pages/home/home_page.dart';
import 'package:ecuscanqr/app/ui/pages/settings/settings_page.dart';
import 'package:ecuscanqr/app/ui/pages/splash/splash_page.dart';
import 'package:ecuscanqr/app/ui/routes/routes.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext)> routes = {
  Routes.about: (_) => const AboutPage(),
  Routes.home: (_) => const HomePage(),
  Routes.splash: (_) => const SplashPage(),
  Routes.settings: (_) => const SettingsPage(),
  Routes.bottomNavBar: (_) => const BottomNavBarPage(),
};

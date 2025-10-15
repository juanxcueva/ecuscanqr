import 'package:flutter_meedu/meedu.dart';
import '../../../routes/routes.dart';

class SplashController extends SimpleNotifier {

  String text = 'Cargando';
  String route = "";
  SplashController() {
    _init();
  }

  bool navigate = false;

  void _init() async {
    await Future.delayed(const Duration(milliseconds: 200));
    notify();

    await Future.delayed(const Duration(milliseconds: 500));
    text = "$text.";
    notify();
    await Future.delayed(const Duration(milliseconds: 500));

    text = "$text.";
    await Future.delayed(const Duration(milliseconds: 500));
    navigate = true;
    route = Routes.bottomNavBar;

    notify();
  }
}

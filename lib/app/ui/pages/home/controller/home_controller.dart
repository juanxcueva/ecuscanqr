import 'package:flutter_meedu/meedu.dart';

class HomeController extends SimpleNotifier {
  // Control de navegación del bottom navbar (solo índice)
  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;

  HomeController();

  // Cambiar de página (sin animaciones, directo)
  void changePage(int index) {
    _currentPageIndex = index;
    notify();
  }
}
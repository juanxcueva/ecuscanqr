import 'dart:convert';
import 'package:ecuscanqr/app/domain/repository/qr_repository.dart';
import 'package:ecuscanqr/app/ui/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:share_plus/share_plus.dart';

class SettingsController extends SimpleNotifier {
  final qrRepository = Get.find<QrRepository>();
  final _storage = Get.find<FlutterSecureStorage>();

  // Usamos ValueNotifier para manejar el cambio de tema dinámicamente
  ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);
  ThemeMode themeMode = ThemeMode.light;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool isDarkMode = false;
  bool _vibrateOnScan = true;
  bool _soundOnScan = true;

  // Estadísticas que se actualizarán
  Map<String, int> _statistics = {};

  bool get vibrateOnScan => _vibrateOnScan;
  bool get soundOnScan => _soundOnScan;
  Map<String, int> get statistics => _statistics;

  SettingsController() {
    _init();
    _loadSettings();
    _loadStatistics();
  }

  // Método público para recargar estadísticas (llamar cuando vuelves a Settings)
  void refreshStatistics() {
    _loadStatistics();
  }

  // Cargar estadísticas
  void _loadStatistics() {
    try {
      _statistics = qrRepository.getStatistics();
      notify();
    } catch (e) {
      print('Error loading statistics: $e');
      _statistics = {
        'total': 0,
        'generated': 0,
        'scanned': 0,
        'favorites': 0,
      };
      notify();
    }
  }

  // Cargar configuraciones guardadas
  Future<void> _loadSettings() async {
    try {
      // Cargar el tema
      final storedTheme = await _storage.read(key: 'darkMode');
      themeModeNotifier.value = storedTheme == 'true'
          ? ThemeMode.dark
          : ThemeMode.light;

      // Cargar otras configuraciones
      _vibrateOnScan =
          qrRepository.getSetting<bool>('vibrate_on_scan', defaultValue: true) ??
          true;
      _soundOnScan =
          qrRepository.getSetting<bool>('sound_on_scan', defaultValue: true) ??
          true;
      isDarkMode = storedTheme == 'true';

      // Notificar cambios
      notify();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  void _init() async {
    try {
      String darkMode = (await _storage.read(key: 'darkMode')) ?? "";
      if (darkMode == "true") {
        themeMode = ThemeMode.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: AppColors.darkColor,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.darkColor,
            statusBarBrightness: Brightness.dark,
          ),
        );
      } else {
        themeMode = ThemeMode.light;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.white,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        );
      }
      notify();
    } catch (e) {
      print('Error initializing settings: $e');
    }
  }

  // Cambiar el tema y guardar la preferencia
  void toggleDarkMode(bool isOn) {
    try {
      if (isOn) {
        themeMode = ThemeMode.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: AppColors.darkColor,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.darkColor,
            statusBarBrightness: Brightness.dark,
          ),
        );
        _storage.write(key: 'darkMode', value: 'true');
      } else {
        themeMode = ThemeMode.light;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.white,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        );
        _storage.write(key: 'darkMode', value: 'false');
      }
      isDarkMode = isOn;
      notify();
    } catch (e) {
      print('Error toggling dark mode: $e');
    }
  }

  // Toggle Vibration
  Future<void> toggleVibration(bool value) async {
    try {
      _vibrateOnScan = value;
      await qrRepository.saveSetting('vibrate_on_scan', value);
      notify();
    } catch (e) {
      print('Error toggling vibration: $e');
    }
  }

  // Toggle Sound
  Future<void> toggleSound(bool value) async {
    try {
      _soundOnScan = value;
      await qrRepository.saveSetting('sound_on_scan', value);
      notify();
    } catch (e) {
      print('Error toggling sound: $e');
    }
  }

  // Exportar historial como JSON
  Future<void> exportHistory(BuildContext context) async {
    try {
      final qrs = qrRepository.getAllQrs();

      if (qrs.isEmpty) {
        _showSnackBar(context, 'No QR codes to export', isError: true);
        return;
      }

      // Convertir a JSON
      final jsonData = qrs.map((qr) {
        return {
          'id': qr.id,
          'type': qr.type,
          'data': qr.data,
          'displayTitle': qr.displayTitle,
          'createdAt': qr.createdAt.toIso8601String(),
          'isFavorite': qr.isFavorite,
          'isScanned': qr.isScanned,
        };
      }).toList();

      final jsonString = const JsonEncoder.withIndent('  ').convert({
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalQrs': qrs.length,
        'qrCodes': jsonData,
      });

      // Compartir el JSON
      await Share.share(
        jsonString,
        subject: 'EcuaScanQR Export - ${qrs.length} QR Codes',
      );

      _showSnackBar(context, 'Exported ${qrs.length} QR codes successfully');
    } catch (e) {
      print('Error exporting history: $e');
      _showSnackBar(context, 'Error exporting: $e', isError: true);
    }
  }

  // Limpiar todos los datos
  Future<void> clearAllData(BuildContext context) async {
    try {
      await qrRepository.clearAllQrs();
      
      // Recargar estadísticas después de limpiar
      _loadStatistics();

      _showSnackBar(context, 'All data cleared successfully');
    } catch (e) {
      print('Error clearing data: $e');
      _showSnackBar(context, 'Error clearing data: $e', isError: true);
    }
  }

  // Vibración (si está habilitada)
  Future<void> vibrate() async {
    if (_vibrateOnScan) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (e) {
        print('Vibration not supported: $e');
      }
    }
  }

  // Mostrar SnackBar
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  // Obtener estadísticas (deprecated, usar el getter)
  @Deprecated('Use statistics getter instead')
  Map<String, int> getStatistics() {
    return _statistics;
  }
}
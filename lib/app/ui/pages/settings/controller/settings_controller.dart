import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:ecuscanqr/app/data/resources/local/hive_storage_service.dart';
import 'package:share_plus/share_plus.dart';

class SettingsController extends SimpleNotifier {
  bool _isDarkMode = false;
  bool _vibrateOnScan = true;
  bool _soundOnScan = true;

  bool get isDarkMode => _isDarkMode;
  bool get vibrateOnScan => _vibrateOnScan;
  bool get soundOnScan => _soundOnScan;

  SettingsController() {
    _loadSettings();
  }

  // Cargar configuraciones guardadas
  Future<void> _loadSettings() async {
    _isDarkMode = HiveStorageService.getSetting<bool>(
          'dark_mode',
          defaultValue: false,
        ) ??
        false;
    _vibrateOnScan = HiveStorageService.getSetting<bool>(
          'vibrate_on_scan',
          defaultValue: true,
        ) ??
        true;
    _soundOnScan = HiveStorageService.getSetting<bool>(
          'sound_on_scan',
          defaultValue: true,
        ) ??
        true;
    notify();
  }

  // Toggle Dark Mode
  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await HiveStorageService.saveSetting('dark_mode', value);
    notify();
  }

  // Toggle Vibration
  Future<void> toggleVibration(bool value) async {
    _vibrateOnScan = value;
    await HiveStorageService.saveSetting('vibrate_on_scan', value);
    notify();
  }

  // Toggle Sound
  Future<void> toggleSound(bool value) async {
    _soundOnScan = value;
    await HiveStorageService.saveSetting('sound_on_scan', value);
    notify();
  }

  // Exportar historial como JSON
  Future<void> exportHistory(BuildContext context) async {
    try {
      final qrs = HiveStorageService.getAllQrs();

      if (qrs.isEmpty) {
        _showSnackBar(
          context,
          'No QR codes to export',
          isError: true,
        );
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

      _showSnackBar(
        context,
        'Exported ${qrs.length} QR codes successfully',
      );
    } catch (e) {
      print('Error exporting history: $e');
      _showSnackBar(
        context,
        'Error exporting: $e',
        isError: true,
      );
    }
  }

  // Limpiar todos los datos
  Future<void> clearAllData(BuildContext context) async {
    try {
      await HiveStorageService.clearAllQrs();
      
      _showSnackBar(
        context,
        'All data cleared successfully',
      );
    } catch (e) {
      print('Error clearing data: $e');
      _showSnackBar(
        context,
        'Error clearing data: $e',
        isError: true,
      );
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  // Obtener estadísticas
  Map<String, int> getStatistics() {
    return HiveStorageService.getStatistics();
  }
}
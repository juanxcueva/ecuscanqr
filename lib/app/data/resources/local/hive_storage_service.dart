import 'package:ecuscanqr/app/domain/model/hive/qr_code_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorageService {
  final String _qrBoxName = 'qr_codes';
  final String _settingsBoxName = 'settings';

  Box<QrCodeModel>? _qrBox;
  Box? _settingsBox;

  // Inicializar Hive
  Future<void> init() async {
    await Hive.initFlutter();

    // Registrar adaptador
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(QrCodeModelAdapter());
    }

    // Abrir boxes
    _qrBox = await Hive.openBox<QrCodeModel>(_qrBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // Verificar si está inicializado
  bool get isInitialized => _qrBox != null && _settingsBox != null;

  /* ------------------------------ QR Codes ------------------------------ */

  // Guardar QR (generado o escaneado)
  Future<void> saveQr(QrCodeModel qr) async {
    if (!isInitialized) await init();
    await _qrBox!.put(qr.id, qr);
  }

  // Obtener todos los QRs
  List<QrCodeModel> getAllQrs() {
    if (!isInitialized) return [];
    return _qrBox!.values.toList()..sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    ); // Más recientes primero
  }

  // Obtener QRs generados
  List<QrCodeModel> getGeneratedQrs() {
    return getAllQrs().where((qr) => !qr.isScanned).toList();
  }

  // Obtener QRs escaneados
  List<QrCodeModel> getScannedQrs() {
    return getAllQrs().where((qr) => qr.isScanned).toList();
  }

  // Obtener favoritos
  List<QrCodeModel> getFavoriteQrs() {
    return getAllQrs().where((qr) => qr.isFavorite).toList();
  }

  // Obtener QR por ID
  QrCodeModel? getQrById(String id) {
    if (!isInitialized) return null;
    return _qrBox!.get(id);
  }

  // Actualizar QR
  Future<void> updateQr(QrCodeModel qr) async {
    if (!isInitialized) await init();
    await _qrBox!.put(qr.id, qr);
  }

  // Eliminar QR
  Future<void> deleteQr(String id) async {
    if (!isInitialized) return;
    await _qrBox!.delete(id);
  }

  // Alternar favorito
  Future<void> toggleFavorite(String id) async {
    final qr = getQrById(id);
    if (qr != null) {
      qr.isFavorite = !qr.isFavorite;
      await updateQr(qr);
    }
  }

  // Limpiar todo el historial
  Future<void> clearAllQrs() async {
    if (!isInitialized) return;
    await _qrBox!.clear();
  }

  // Limpiar solo generados
  Future<void> clearGeneratedQrs() async {
    if (!isInitialized) return;
    final generated = getGeneratedQrs();
    for (var qr in generated) {
      await deleteQr(qr.id);
    }
  }

  // Limpiar solo escaneados
  Future<void> clearScannedQrs() async {
    if (!isInitialized) return;
    final scanned = getScannedQrs();
    for (var qr in scanned) {
      await deleteQr(qr.id);
    }
  }

  // Buscar QRs
  List<QrCodeModel> searchQrs(String query) {
    if (query.isEmpty) return getAllQrs();

    final lowerQuery = query.toLowerCase();
    return getAllQrs().where((qr) {
      return qr.displayTitle.toLowerCase().contains(lowerQuery) ||
          qr.data.toLowerCase().contains(lowerQuery) ||
          qr.type.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filtrar por tipo
  List<QrCodeModel> filterByType(String type) {
    return getAllQrs().where((qr) => qr.type == type).toList();
  }

  // Obtener estadísticas
  Map<String, int> getStatistics() {
    final all = getAllQrs();
    return {
      'total': all.length,
      'generated': getGeneratedQrs().length,
      'scanned': getScannedQrs().length,
      'favorites': getFavoriteQrs().length,
      'website': filterByType('website').length,
      'text': filterByType('text').length,
      'email': filterByType('email').length,
      'sms': filterByType('sms').length,
      'wifi': filterByType('wifi').length,
    };
  }

  /* ------------------------------ Settings ------------------------------ */

  // Guardar configuración
  Future<void> saveSetting(String key, dynamic value) async {
    if (!isInitialized) await init();
    await _settingsBox!.put(key, value);
  }

  // Obtener configuración
  T? getSetting<T>(String key, {T? defaultValue}) {
    if (!isInitialized) return defaultValue;
    return _settingsBox!.get(key, defaultValue: defaultValue) as T?;
  }

  // Cerrar Hive (llamar al cerrar la app)
  Future<void> close() async {
    await _qrBox?.close();
    await _settingsBox?.close();
  }
}

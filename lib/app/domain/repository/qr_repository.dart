import 'package:ecuscanqr/app/domain/model/hive/qr_code_model.dart';

abstract class QrRepository {
  Future<void> saveQr(QrCodeModel qr);
  List<QrCodeModel> getAllQrs();
  List<QrCodeModel> getGeneratedQrs();
  List<QrCodeModel> getScannedQrs();
  List<QrCodeModel> getFavoriteQrs();
  QrCodeModel? getQrById(String id);
  Future<void> updateQr(QrCodeModel qr);
  Future<void> deleteQr(String id);
  Future<void> toggleFavorite(String id);
  Future<void> clearAllQrs();
  Future<void> clearGeneratedQrs();
  Future<void> clearScannedQrs();
  List<QrCodeModel> searchQrs(String query);
  List<QrCodeModel> filterByType(String type);
  Map<String, int> getStatistics();
  Future<void> saveSetting(String key, dynamic value);
  T? getSetting<T>(String key, {T? defaultValue});
}

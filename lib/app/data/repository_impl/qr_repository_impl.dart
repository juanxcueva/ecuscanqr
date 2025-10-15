import 'package:ecuscanqr/app/data/resources/local/hive_storage_service.dart';
import 'package:ecuscanqr/app/domain/repository/qr_repository.dart';
import 'package:ecuscanqr/app/domain/model/hive/qr_code_model.dart';

class QrRepositoryImpl extends QrRepository {
  // Dependencia del servicio Hive
  final HiveStorageService _hiveStorageService;

  QrRepositoryImpl(this._hiveStorageService);

  @override
  Future<void> saveQr(QrCodeModel qr) async {
    return await _hiveStorageService.saveQr(qr);
  }

  @override
  List<QrCodeModel> getAllQrs() {
    return _hiveStorageService.getAllQrs();
  }

  @override
  List<QrCodeModel> getGeneratedQrs() {
    return _hiveStorageService.getGeneratedQrs();
  }

  @override
  List<QrCodeModel> getScannedQrs() {
    return _hiveStorageService.getScannedQrs();
  }

  @override
  List<QrCodeModel> getFavoriteQrs() {
    return _hiveStorageService.getFavoriteQrs();
  }

  @override
  QrCodeModel? getQrById(String id) {
    return _hiveStorageService.getQrById(id);
  }

  @override
  Future<void> updateQr(QrCodeModel qr) async {
    return await _hiveStorageService.updateQr(qr);
  }

  @override
  Future<void> deleteQr(String id) async {
    return await _hiveStorageService.deleteQr(id);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    return await _hiveStorageService.toggleFavorite(id);
  }

  @override
  Future<void> clearAllQrs() async {
    return await _hiveStorageService.clearAllQrs();
  }

  @override
  Future<void> clearGeneratedQrs() async {
    return await _hiveStorageService.clearGeneratedQrs();
  }

  @override
  Future<void> clearScannedQrs() async {
    return await _hiveStorageService.clearScannedQrs();
  }

  @override
  List<QrCodeModel> searchQrs(String query) {
    return _hiveStorageService.searchQrs(query);
  }

  @override
  List<QrCodeModel> filterByType(String type) {
    return _hiveStorageService.filterByType(type);
  }

  @override
  Map<String, int> getStatistics() {
    return _hiveStorageService.getStatistics();
  }

  @override
  Future<void> saveSetting(String key, dynamic value) async {
    await _hiveStorageService.saveSetting(key, value);
  }

  @override
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _hiveStorageService.getSetting<T>(key, defaultValue: defaultValue);
  }
}

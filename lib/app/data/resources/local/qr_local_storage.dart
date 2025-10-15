import 'dart:convert';
import 'package:ecuscanqr/app/domain/model/qr_type_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecuscanqr/app/domain/model/qr_data_model.dart';

class QrLocalStorage {
  static const String _historyKey = 'qr_history';
  static const String _favoritesKey = 'qr_favorites';
  static const int _maxHistoryItems = 100;

  final SharedPreferences _prefs;

  QrLocalStorage(this._prefs);

  // Factory para inicializar
  static Future<QrLocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return QrLocalStorage(prefs);
  }

  // Guardar QR en historial
  Future<bool> saveQr(QrDataModel qr) async {
    try {
      final history = await getHistory();
      
      // Evitar duplicados
      history.removeWhere((item) => item.id == qr.id);
      
      // Agregar al inicio
      history.insert(0, qr);
      
      // Limitar tamaño del historial
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }
      
      // Guardar
      final jsonList = history.map((e) => e.toJson()).toList();
      return await _prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving QR: $e');
      return false;
    }
  }

  // Obtener historial
  Future<List<QrDataModel>> getHistory() async {
    try {
      final jsonString = _prefs.getString(_historyKey);
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => QrDataModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting history: $e');
      return [];
    }
  }

  // Eliminar QR del historial
  Future<bool> deleteQr(String id) async {
    try {
      final history = await getHistory();
      history.removeWhere((qr) => qr.id == id);
      
      final jsonList = history.map((e) => e.toJson()).toList();
      return await _prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error deleting QR: $e');
      return false;
    }
  }

  // Limpiar todo el historial
  Future<bool> clearHistory() async {
    try {
      return await _prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing history: $e');
      return false;
    }
  }

  // Toggle favorito
  Future<bool> toggleFavorite(String id) async {
    try {
      final history = await getHistory();
      final index = history.indexWhere((qr) => qr.id == id);
      
      if (index != -1) {
        history[index] = history[index].copyWith(
          isFavorite: !history[index].isFavorite,
        );
        
        final jsonList = history.map((e) => e.toJson()).toList();
        return await _prefs.setString(_historyKey, jsonEncode(jsonList));
      }
      return false;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Obtener favoritos
  Future<List<QrDataModel>> getFavorites() async {
    final history = await getHistory();
    return history.where((qr) => qr.isFavorite).toList();
  }

  // Buscar en historial
  Future<List<QrDataModel>> searchHistory(String query) async {
    final history = await getHistory();
    final lowerQuery = query.toLowerCase();
    
    return history.where((qr) {
      return qr.displayTitle.toLowerCase().contains(lowerQuery) ||
             qr.data.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Obtener por tipo
  Future<List<QrDataModel>> getByType(QrType type) async {
    final history = await getHistory();
    return history.where((qr) => qr.type == type).toList();
  }
}
import 'package:ecuscanqr/app/domain/model/hive/qr_code_model.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:ecuscanqr/app/data/resources/local/hive_storage_service.dart';

class HistoryController extends SimpleNotifier {
  List<QrCodeModel> _allQrs = [];
  List<QrCodeModel> _filteredQrs = [];
  String _selectedFilter = 'all'; // 'all', 'generated', 'scanned', 'favorites'
  String _searchQuery = '';
  bool _isLoading = false;

  List<QrCodeModel> get filteredQrs => _filteredQrs;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  int get totalCount => _allQrs.length;

  HistoryController() {
    loadHistory();
  }

  // Cargar historial desde Hive
  Future<void> loadHistory() async {
    _isLoading = true;
    notify();

    try {
      _allQrs = HiveStorageService.getAllQrs();
      _applyFilters();
    } catch (e) {
      print('Error loading history: $e');
      _allQrs = [];
      _filteredQrs = [];
    } finally {
      _isLoading = false;
      notify();
    }
  }

  // Aplicar filtros
  void _applyFilters() {
    List<QrCodeModel> result = [];

    // Filtro por categoría
    switch (_selectedFilter) {
      case 'all':
        result = _allQrs;
        break;
      case 'generated':
        result = HiveStorageService.getGeneratedQrs();
        break;
      case 'scanned':
        result = HiveStorageService.getScannedQrs();
        break;
      case 'favorites':
        result = HiveStorageService.getFavoriteQrs();
        break;
      default:
        result = _allQrs;
    }

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((qr) {
        return qr.displayTitle.toLowerCase().contains(query) ||
               qr.data.toLowerCase().contains(query) ||
               qr.type.toLowerCase().contains(query);
      }).toList();
    }

    _filteredQrs = result;
    notify();
  }

  // Cambiar filtro
  void changeFilter(String filter) {
    _selectedFilter = filter;
    _applyFilters();
  }

  // Buscar
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Alternar favorito
  Future<void> toggleFavorite(String id) async {
    await HiveStorageService.toggleFavorite(id);
    await loadHistory();
  }

  // Eliminar QR
  Future<void> deleteQr(String id) async {
    await HiveStorageService.deleteQr(id);
    await loadHistory();
  }

  // Limpiar historial según filtro
  Future<void> clearHistory() async {
    switch (_selectedFilter) {
      case 'all':
        await HiveStorageService.clearAllQrs();
        break;
      case 'generated':
        await HiveStorageService.clearGeneratedQrs();
        break;
      case 'scanned':
        await HiveStorageService.clearScannedQrs();
        break;
      default:
        await HiveStorageService.clearAllQrs();
    }
    await loadHistory();
  }

  // Obtener estadísticas
  Map<String, int> getStatistics() {
    return HiveStorageService.getStatistics();
  }

  @override
  void dispose() {
    _allQrs.clear();
    _filteredQrs.clear();
    super.dispose();
  }
}
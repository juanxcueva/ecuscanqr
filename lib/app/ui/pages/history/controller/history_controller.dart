import 'package:ecuscanqr/app/domain/model/hive/qr_code_model.dart';
import 'package:ecuscanqr/app/domain/repository/qr_repository.dart';
import 'package:flutter_meedu/meedu.dart';

class HistoryController extends SimpleNotifier {
  final qrRepository = Get.find<QrRepository>();
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
      _allQrs = qrRepository.getAllQrs();
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
        result = qrRepository.getGeneratedQrs();
        break;
      case 'scanned':
        result = qrRepository.getScannedQrs();
        break;
      case 'favorites':
        result = qrRepository.getFavoriteQrs();
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
    await qrRepository.toggleFavorite(id);
    await loadHistory();
  }

  // Eliminar QR
  Future<void> deleteQr(String id) async {
    await qrRepository.deleteQr(id);
    await loadHistory();
  }

  // Limpiar historial según filtro
  Future<void> clearHistory() async {
    switch (_selectedFilter) {
      case 'all':
        await qrRepository.clearAllQrs();
        break;
      case 'generated':
        await qrRepository.clearGeneratedQrs();
        break;
      case 'scanned':
        await qrRepository.clearScannedQrs();
        break;
      default:
        await qrRepository.clearAllQrs();
    }
    await loadHistory();
  }

  // Obtener estadísticas
  Map<String, int> getStatistics() {
    return qrRepository.getStatistics();
  }

  @override
  void dispose() {
    _allQrs.clear();
    _filteredQrs.clear();
    super.dispose();
  }
}
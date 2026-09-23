import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:flutter/foundation.dart';

final class AdminCatalogSearchController extends ChangeNotifier {
  AdminCatalogSearchController({
    required String Function(Object error) formatError,
  }) : _formatError = formatError;

  final String Function(Object error) _formatError;

  List<AdminMetadataItem> _items = const [];
  String? _kindFilter;
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _statusMessage;
  String? _errorMessage;
  int _generation = 0;
  bool _disposed = false;

  List<AdminMetadataItem> get items => _items;
  String? get kindFilter => _kindFilter;
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;
  String? get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;

  set statusMessage(String? value) {
    _statusMessage = value;
    _notifyListeners();
  }

  set errorMessage(String? value) {
    _errorMessage = value;
    _notifyListeners();
  }

  set kindFilter(String? value) {
    if (_kindFilter == value) return;
    _kindFilter = value;
    _notifyListeners();
  }

  Future<void> search(ApiClient api, {required String query}) async {
    final normalizedQuery = query.trim();
    final kind = _kindFilter;
    final generation = ++_generation;
    if (normalizedQuery.isEmpty && (kind == null || kind.isEmpty)) {
      _items = const [];
      _hasSearched = false;
      _isSearching = false;
      _errorMessage = null;
      _statusMessage =
          'Enter a title or choose a category before searching the catalog.';
      _notifyListeners();
      return;
    }

    _isSearching = true;
    _hasSearched = true;
    _statusMessage = null;
    _errorMessage = null;
    _notifyListeners();
    try {
      final items = await api.adminCatalogItems(
        query: normalizedQuery,
        kind: kind,
        limit: 12,
      );
      if (generation != _generation) return;
      _items = items;
      _statusMessage = items.isEmpty
          ? 'No catalog items matched the current search.'
          : '${items.length} catalog items found.';
    } catch (error) {
      if (generation != _generation) return;
      _errorMessage = _formatError(error);
    } finally {
      if (generation == _generation) {
        _isSearching = false;
        _notifyListeners();
      }
    }
  }

  void replaceItem(AdminMetadataItem updated) {
    _items = [
      for (final item in _items) item.id == updated.id ? updated : item,
    ];
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/admin/admin_page_data_loader.dart';
import 'package:flutter/foundation.dart';

final class AdminProposalsController extends ChangeNotifier {
  AdminProposalsController({
    required String Function(Object error) formatError,
  }) : _formatError = formatError;

  final String Function(Object error) _formatError;

  List<AdminMetadataProposal> _proposals = const [];
  AdminMetadataProposalSummary? _summary;
  String _statusFilter = 'pending';
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;
  int _loadGeneration = 0;

  List<AdminMetadataProposal> get proposals => _proposals;

  AdminMetadataProposalSummary? get summary => _summary;
  String get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  set statusFilter(String value) {
    if (_statusFilter == value) return;
    _statusFilter = value;
    _errorMessage = null;
    _notifyListeners();
  }

  Future<void> load(ApiClient api) async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    _errorMessage = null;
    _notifyListeners();
    try {
      final data = await AdminPageDataLoader(api).loadProposals(
        status: _statusFilter,
      );
      if (generation == _loadGeneration) {
        _summary = data.summary;
        _proposals = data.proposals;
      }
    } catch (error) {
      if (generation == _loadGeneration) {
        _errorMessage = _formatError(error);
      }
    } finally {
      if (generation == _loadGeneration) {
        _isLoading = false;
        _notifyListeners();
      }
    }
  }

  Future<AdminMetadataProposal> approve(
    ApiClient api, {
    required String proposalId,
  }) =>
      api.adminApproveMetadataProposal(proposalId: proposalId);

  Future<void> reject(ApiClient api, {required String proposalId}) =>
      api.adminRejectMetadataProposal(proposalId: proposalId);

  Future<AdminMetadataProposal> update(
    ApiClient api, {
    required String proposalId,
    required Map<String, Object?> catalogItem,
    String? reviewNote,
  }) =>
      api.adminUpdateMetadataProposal(
        proposalId: proposalId,
        catalogItem: Map<String, dynamic>.from(catalogItem),
        reviewNote: reviewNote,
      );

  void replaceProposal(AdminMetadataProposal updated) {
    _proposals = [
      for (final proposal in _proposals)
        proposal.id == updated.id ? updated : proposal,
    ];
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _loadGeneration++;
    super.dispose();
  }
}

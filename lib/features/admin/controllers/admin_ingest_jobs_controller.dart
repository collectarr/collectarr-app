import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/admin/admin_page_data_loader.dart';
import 'package:flutter/foundation.dart';

final class AdminIngestJobsController extends ChangeNotifier {
  AdminIngestJobsController({
    required String Function(Object error) formatError,
  }) : _formatError = formatError;

  final String Function(Object error) _formatError;

  List<AdminProviderIngestHistoryEntry> _history = const [];
  List<AdminProviderIngestJob> _jobs = const [];
  AdminProviderIngestJobSummary? _summary;
  DateTime? _refreshedAt;
  String? _statusFilter;
  String? _providerFilter;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;
  int _refreshGeneration = 0;

  List<AdminProviderIngestHistoryEntry> get history => _history;
  List<AdminProviderIngestJob> get jobs => _jobs;
  AdminProviderIngestJobSummary? get summary => _summary;
  DateTime? get refreshedAt => _refreshedAt;
  String? get statusFilter => _statusFilter;
  String? get providerFilter => _providerFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasPollableJobs {
    final summary = _summary;
    final summaryHasActiveJobs = summary != null &&
        (summary.queued > 0 ||
            summary.running > 0 ||
            summary.dueQueued > 0 ||
            summary.staleRunning > 0);
    return summaryHasActiveJobs ||
        _jobs.any((job) => job.isQueued || job.isRunning);
  }

  void setFilters({String? status, String? provider}) {
    _statusFilter = status;
    _providerFilter = provider;
    _notifyListeners();
  }

  void acceptDashboard(AdminDashboardData dashboard) {
    _history = dashboard.ingestHistory;
    _summary = dashboard.ingestJobSummary;
    _jobs = dashboard.ingestJobs;
    _refreshedAt = DateTime.now().toUtc();
    _notifyListeners();
  }

  Future<void> refresh(
    ApiClient api, {
    required String? query,
    bool silent = false,
  }) async {
    final generation = ++_refreshGeneration;
    _setLoading(true);
    if (!silent) _errorMessage = null;
    try {
      final data = await AdminPageDataLoader(api).loadIngestJobs(
        status: _statusFilter,
        provider: _providerFilter,
        query: query,
      );
      if (generation == _refreshGeneration) {
        _history = data.history;
        _summary = data.summary;
        _jobs = data.jobs;
        _refreshedAt = DateTime.now().toUtc();
      }
    } catch (error) {
      if (generation == _refreshGeneration && !silent) {
        _errorMessage = _formatError(error);
      }
    } finally {
      if (generation == _refreshGeneration) _setLoading(false);
    }
  }

  Future<AdminProviderIngestJob> queue(
    ApiClient api, {
    required String provider,
    required String providerItemId,
  }) =>
      api.adminCreateProviderIngestJob(
        provider: provider,
        providerItemId: providerItemId,
      );

  Future<AdminProviderIngestJobRunResult> runPending(
    ApiClient api, {
    int limit = 5,
  }) =>
      api.adminRunPendingProviderIngestJobs(limit: limit);

  Future<AdminProviderIngestJob> runJob(
    ApiClient api, {
    required String jobId,
    required bool retry,
  }) =>
      retry
          ? api.adminRetryProviderIngestJob(jobId: jobId)
          : api.adminRunProviderIngestJob(jobId: jobId);

  Future<AdminProviderIngestResult> retryHistory(
    ApiClient api, {
    required int historyId,
  }) =>
      api.adminRetryProviderIngest(historyId: historyId);

  void _setLoading(bool value) {
    _isLoading = value;
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _refreshGeneration++;
    super.dispose();
  }
}

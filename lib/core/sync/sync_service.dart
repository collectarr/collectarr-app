import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';

class SyncService {
  const SyncService(this._apiClient, {required this.deviceId});

  final ApiClient _apiClient;
  final String deviceId;

  Future<void> pushPending(List<SyncChange> changes) async {
    await _apiClient.pushSync(
      changes.map((change) => change.toJson()).toList(),
      deviceId: deviceId,
    );
  }

  Future<Map<String, dynamic>> pull({DateTime? since}) {
    return _apiClient.pullSync(since: since);
  }
}

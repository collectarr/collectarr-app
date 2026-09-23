import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';

final class SettingsDiagnosticState {
  const SettingsDiagnosticState.checking()
      : isChecking = true,
        isOk = false,
        message = '';

  const SettingsDiagnosticState.ok(this.message)
      : isChecking = false,
        isOk = true;

  const SettingsDiagnosticState.error(this.message)
      : isChecking = false,
        isOk = false;

  final bool isChecking;
  final bool isOk;
  final String message;
}

final class SettingsSyncDiagnosticResult {
  const SettingsSyncDiagnosticResult({
    required this.diagnostic,
    this.statusDetails,
    this.devices = const [],
  });

  final SettingsDiagnosticState diagnostic;
  final Map<String, dynamic>? statusDetails;
  final List<Map<String, dynamic>> devices;
}

final class SettingsConnectionDiagnosticsService {
  const SettingsConnectionDiagnosticsService();

  Future<SettingsDiagnosticState> checkMetadata(String baseUrl) async {
    try {
      final data = await ApiClient(baseUrl: baseUrl.trim()).health();
      final status = data['status']?.toString() ?? 'unknown';
      return SettingsDiagnosticState.ok('Metadata server: $status');
    } catch (error) {
      return SettingsDiagnosticState.error(
        ConnectionDiagnostics.metadataError(error, baseUrl),
      );
    }
  }

  Future<SettingsSyncDiagnosticResult> checkSync({
    required String baseUrl,
    required String syncKey,
  }) async {
    try {
      final client = CollectarrSyncClient(
        baseUrl: baseUrl,
        syncKey: syncKey,
      );
      final data = await client.status();
      final devices = await client.devices();
      final protocol = data['protocol_version']?.toString() ?? 'unknown';
      final version = data['schema_version']?.toString() ?? 'unknown';
      final entities = data['entity_count']?.toString() ?? 'unknown';
      final changes = data['change_count']?.toString() ?? 'unknown';
      return SettingsSyncDiagnosticResult(
        diagnostic: SettingsDiagnosticState.ok(
          'Sync connected: protocol $protocol, schema $version, $entities entities, $changes events',
        ),
        statusDetails: data,
        devices: devices,
      );
    } catch (error) {
      return SettingsSyncDiagnosticResult(
        diagnostic: SettingsDiagnosticState.error(
          ConnectionDiagnostics.syncError(error, baseUrl),
        ),
      );
    }
  }
}

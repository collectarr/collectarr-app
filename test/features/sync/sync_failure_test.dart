import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/logging/app_log.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/sync/data/sync_repository.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/features/sync/state/sync_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fakes/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    setUpSecureStorageMock();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(DeviceIdentity.resetForTesting);

  test('sync failure preserves pending changes and links the full diagnostic',
      () async {
    late _UnavailableSyncRepository repository;
    final container = ProviderContainer(overrides: [
      syncRepositoryProvider.overrideWith((ref) {
        repository = _UnavailableSyncRepository(ref);
        return repository;
      }),
    ]);
    addTearDown(container.dispose);
    final controller = container.read(syncControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.syncNow();
    await Future<void>.delayed(Duration.zero);
    final state = container.read(syncControllerProvider);
    expect(repository.calls, 1);
    expect(state, isA<SyncFailure>());
    expect(state.isOffline, isTrue);
    expect(state.pendingCount, 7);
    expect(state.errorMessage, contains('Cannot reach the sync service'));
    expect(state.errorMessage, isNot(contains('DioException')));
    final diagnostic = container.read(appLogProvider).single;
    expect(diagnostic.message, contains('DioException'));
    expect(diagnostic.detail, isNotEmpty);
    expect(diagnostic.timestamp, state.syncLog.single.timestamp);
  });
}

class _UnavailableSyncRepository extends SyncRepository {
  _UnavailableSyncRepository(super.ref);
  int calls = 0;
  @override
  Future<int> getPendingCount() async => 7;
  @override
  Future<DateTime?> getLastSyncedAt() async => null;
  @override
  Future<List<SyncRejectedChange>> readConflicts() async => [];
  @override
  Future<SyncResult> performSync(String deviceId) async {
    calls++;
    throw DioException(
        requestOptions: RequestOptions(path: '/health'),
        type: DioExceptionType.connectionError,
        message: 'Connection refused');
  }
}

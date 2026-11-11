import 'dart:async';

import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup_controller.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/main.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/accessibility/semantics_recording_binding.dart';
import '../support/app/provider_overrides.dart';
import '../support/app/test_app_harness.dart';

void main() {
  final binding =
      TestWidgetsFlutterBinding.instance as SemanticsRecordingTestBinding;
  for (final kind in ['music', 'game']) {
    for (final restoring in [true, false]) {
      testWidgets(
          'startup semantics retain every node ($kind, restoring=$restoring)',
          (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        tester.view.physicalSize = const Size(1440, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        setUpTestAppPreferences();
        final database = LocalDatabase(NativeDatabase.memory());
        addTearDown(database.close);
        await tester.runAsync(() async {
          await database.customSelect('SELECT 1').get();
          if (kind == 'game') {
            await GameEntryRepository(database).upsertAll(List.generate(
                40,
                (index) => GameLibraryEntry(
                      id: LibraryEntryId('startup-$index'),
                      metadata:
                          GameCatalogMetadata(title: 'Startup Game $index'),
                      updatedAt: DateTime.utc(2026),
                    )));
          }
        });
        final container = ProviderContainer(overrides: [
          localDatabaseProvider.overrideWithValue(database),
          authControllerProvider.overrideWith(() => _StartupAuth(restoring)),
          syncControllerProvider.overrideWith(NoOpSyncFake.new),
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          automaticBackupProvider.overrideWith(_NoAutomaticBackups.new),
        ]);
        container.read(selectedLibraryKindProvider.notifier).select(kind);
        binding.orphans.clear();
        binding.nodes.clear();
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(UncontrolledProviderScope(
              container: container, child: const CollectarrApp()));
          for (var frame = 0; frame < 90; frame++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 60)));
          for (var frame = 0; frame < 90; frame++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
          expect(find.byType(AppShell), findsOneWidget);
          expect(binding.orphans, isEmpty,
              reason:
                  'Every serialized startup node must belong to the retained accessibility tree.');
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(milliseconds: 100));
        } finally {
          semantics.dispose();
          container.dispose();
          await tester.pump(const Duration(milliseconds: 100));
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }
  }
}

class _StartupAuth extends AuthController {
  _StartupAuth(this.restoring);
  final bool restoring;
  @override
  AuthState build() {
    if (!restoring) return const AuthState();
    final timer = Timer(const Duration(milliseconds: 80), () {
      if (ref.mounted) state = const AuthState();
    });
    ref.onDispose(timer.cancel);
    return const AuthState(isRestoring: true);
  }
}

class _NoAutomaticBackups extends AutomaticBackupController {
  @override
  Future<void> backUpIfDue() async {}
}

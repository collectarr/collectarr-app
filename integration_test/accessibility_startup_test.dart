import 'dart:async';

import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup_controller.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/main.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/app/provider_overrides.dart';
import '../test/support/app/test_app_harness.dart';
import '../test/support/fixtures/test_constants.dart';

class _RestoringAuth extends AuthController {
  @override
  AuthState build() {
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('startup and account navigation retain Windows accessibility',
      (tester) async {
    setUpTestAppPreferences();
    final database = LocalDatabase(NativeDatabase.memory());
    final container = ProviderContainer(overrides: [
      localDatabaseProvider.overrideWithValue(database),
      authControllerProvider.overrideWith(_RestoringAuth.new),
      syncControllerProvider.overrideWith(NoOpSyncFake.new),
      mediaCatalogProvider.overrideWith((ref) async => fallbackMediaCatalog),
      automaticBackupProvider.overrideWith(_NoAutomaticBackups.new),
    ]);
    container.read(selectedLibraryKindProvider.notifier).select('game');
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(UncontrolledProviderScope(
          container: container, child: const CollectarrApp()));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(Slider), findsWidgets);
      await tester.tap(find.byKey(const Key('app.account')));
      await pumpUntilSettled(tester);
      await tester.tap(find.text('My Account'));
      await pumpUntilSettled(tester);
      expect(find.text('Library totals on this device'), findsOneWidget);
      await tester.tap(find.text('Back').first);
      await pumpUntilSettled(tester);
      expect(find.byType(Slider), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      await tester.tap(find.text('Settings'));
      await pumpUntilSettled(tester);
      final covers = find.widgetWithText(Tab, 'Covers & layout');
      await tester.ensureVisible(covers);
      await tester.tap(covers);
      await pumpUntilSettled(tester);
      expect(find.text('Grid spacing'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpUntilSettled(tester);
    } finally {
      semantics.dispose();
      container.dispose();
      await database.close();
    }
  });
}

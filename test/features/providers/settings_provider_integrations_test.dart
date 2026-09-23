import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_registry.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_account_store.dart';
import 'package:collectarr_app/features/providers/runtime/provider_registry_provider.dart';
import 'package:collectarr_app/features/settings/settings_provider_integrations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockPersonalReadWrite
    implements PersonalListReadCapability, PersonalListWriteCapability {
  @override
  Future<List<ProviderPersonalEntry>> readPersonalList({
    required String accountId,
    dynamic kind,
    dynamic context,
  }) async =>
      [];

  @override
  Future<void> writePersonalEntry({
    required String accountId,
    required ProviderPersonalEntry entry,
    dynamic context,
  }) async {}

  @override
  Future<void> deletePersonalEntry({
    required String accountId,
    required String remoteItemId,
    String? remoteEntryId,
    dynamic kind,
    dynamic context,
  }) async {}
}

void main() {
  group('Settings provider integrations', () {
    testWidgets('shows connected accounts and compact catalog sources',
        (tester) async {
      final mockReadWrite = _MockPersonalReadWrite();
      final aniListConnector = ProviderConnector(
        id: ProviderId.aniList,
        descriptor: const ProviderDescriptor(
          name: 'anilist',
          displayName: 'AniList',
          kind: CatalogMediaKind.anime,
          supportedKinds: [CatalogMediaKind.anime, CatalogMediaKind.manga],
        ),
        personalRead: mockReadWrite,
        personalWrite: mockReadWrite,
      );

      final openLibraryConnector =
          defaultProviderConnectorRegistry.getById(ProviderId.openLibrary)!;

      final registry = InMemoryProviderConnectorRegistry([
        aniListConnector,
        openLibraryConnector,
      ]);

      final accountStore = InMemoryProviderAccountStore();
      await accountStore.saveAccount(
        ProviderAccount(
          id: 'anilist-123',
          provider: ProviderId.aniList,
          displayName: 'Test Otaku',
          authType: ProviderAuthType.accessToken,
          remoteHandle: 'test_otaku',
          lastSyncAt: DateTime.utc(2026, 8, 31, 12, 0),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            providerRegistryProvider.overrideWith((ref) async => registry),
            providerAccountStoreProvider.overrideWithValue(accountStore),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                children: const [
                  SettingsProviderAccountsPanel(),
                  SettingsCatalogSourcesPanel(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Account management stays directly within Settings.
      expect(find.text('AniList'), findsOneWidget);
      expect(find.textContaining('Test Otaku'), findsOneWidget);
      expect(find.text('Sync now'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);

      await tester.tap(find.text('Metadata sources'));
      await tester.pumpAndSettle();
      expect(find.text('Open Library'), findsOneWidget);
    });
  });
}

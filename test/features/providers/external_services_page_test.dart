import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_registry.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_account_store.dart';
import 'package:collectarr_app/features/providers/runtime/provider_registry_provider.dart';
import 'package:collectarr_app/features/providers/ui/external_services_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockPersonalReadWrite implements PersonalListReadCapability, PersonalListWriteCapability {
  @override
  Future<List<ProviderPersonalEntry>> readPersonalList({
    required String accountId,
    dynamic kind,
    dynamic context,
  }) async => [];

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

class _MockFileImport implements FileImportCapability {
  @override
  Future<List<ProviderPersonalEntry>> parseFile(String content, {String? filename}) async => [];
}

void main() {
  group('PR 23: External Services UI', () {
    testWidgets('renders connectors and derives dynamic capability chips', (tester) async {
      final mockReadWrite = _MockPersonalReadWrite();
      final mockImport = _MockFileImport();

      final aniListConnector = ProviderConnector(
        id: ProviderId.aniList,
        descriptor: const ProviderDescriptor(
          name: 'anilist',
          displayName: 'AniList',
          kind: 'anime',
          supportedKinds: ['anime', 'manga'],
        ),
        personalRead: mockReadWrite,
        personalWrite: mockReadWrite,
        fileImport: mockImport,
      );

      final openLibraryConnector = ProviderConnector(
        id: ProviderId.openLibrary,
        descriptor: const ProviderDescriptor(
          name: 'openlibrary',
          displayName: 'Open Library',
          kind: 'book',
        ),
      );

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
          child: const MaterialApp(
            home: ExternalServicesPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Provider titles rendered
      expect(find.text('AniList'), findsOneWidget);
      expect(find.text('Open Library'), findsOneWidget);

      // Verify dynamically derived capability chips for AniList
      expect(find.text('File Import'), findsOneWidget);
      expect(find.text('Pull Sync'), findsOneWidget);
      expect(find.text('Push Sync'), findsOneWidget);
      expect(find.text('2-Way Sync'), findsOneWidget);

      // Verify connected account info
      expect(find.text('CONNECTED'), findsOneWidget);
      expect(find.textContaining('Test Otaku'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);
    });
  });
}

import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/metadata/provider_status_provider.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/library_add_test_harness.dart';

void main() {
  testWidgets('provider preview explains owned digital copy type', (
    tester,
  ) async {
    configureLibraryAddDesktopViewport(tester);

    final api = _PreviewOwnershipApiClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          authControllerProvider.overrideWith((ref) => TestAdminAuthController(ref)),
          mediaCatalogProvider.overrideWith((ref) async => _testMediaCatalog),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: mangaLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('library-add-query-field')),
      'Naruto',
    );
    await tester.tap(find.text('Search Manga'));
    await tester.pumpAndSettle();

    final candidate = find.byKey(
      const ValueKey('provider:anilist:manga:anilist-1'),
    );
    await tester.ensureVisible(candidate);
    await tester.tap(candidate);
    await tester.pumpAndSettle();

    expect(api.providerPreviewCallCount, 1);
    expect(
      find.text(
        'Provider metadata loaded directly from search results. Owned items from this result will be saved as Digital copy.',
      ),
      findsOneWidget,
    );
  });
}

const _testMediaCatalog = <CatalogMediaType>[
  CatalogMediaType(
    kind: 'manga',
    singularLabel: 'Manga',
    pluralLabel: 'Manga',
    defaultProvider: 'anilist',
    providers: ['anilist'],
    physicalFormats: [
      CatalogPhysicalFormat(
        id: 'ebook',
        label: 'eBook',
        mediaFamily: 'print',
        variantType: 'digital',
      ),
      CatalogPhysicalFormat(
        id: 'paperback',
        label: 'Paperback',
        mediaFamily: 'print',
        variantType: 'physical',
      ),
    ],
  ),
];

class _PreviewOwnershipApiClient extends ApiClient {
  _PreviewOwnershipApiClient() : super(baseUrl: 'http://unused');

  int providerPreviewCallCount = 0;

  @override
  Future<List<Map<String, dynamic>>> searchMetadata(query) async {
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<List<Map<String, dynamic>>> searchProvider({
    String? provider,
    required String query,
    String? kind,
    String? series,
    String? issueNumber,
    int? year,
  }) async {
    return const [
      {
        'provider': 'anilist',
        'provider_item_id': 'anilist-1',
        'title': 'Naruto Vol. 1',
        'kind': 'manga',
        'summary': 'Digital manga candidate.',
        'image_url': 'https://example.test/naruto.jpg',
        'publisher': 'Shueisha',
      },
    ];
  }

  @override
  Future<AdminProviderPreview> providerPreview({
    required String provider,
    required String providerItemId,
  }) async {
    providerPreviewCallCount += 1;
    return const AdminProviderPreview(
      provider: 'anilist',
      providerItemId: 'anilist-1',
      kind: 'manga',
      title: 'Naruto Vol. 1',
      synopsis: 'Provider preview for a digital manga copy.',
      publisher: 'Shueisha',
      physicalFormat: 'ebook',
      physicalFormatLabel: 'eBook',
    );
  }

  @override
  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    return _testMediaCatalog;
  }
}

import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/features/library/add/services/library_add_workflow_service.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildPreviewCatalogItemId is stable', () {
    const service = LibraryAddWorkflowService();

    final first = service.buildPreviewCatalogItemId(
      kind: 'comic',
      provider: 'gcd',
      providerItemId: '123',
    );
    final second = service.buildPreviewCatalogItemId(
      kind: 'comic',
      provider: 'gcd',
      providerItemId: '123',
    );
    final different = service.buildPreviewCatalogItemId(
      kind: 'comic',
      provider: 'gcd',
      providerItemId: '456',
    );

    expect(first, second);
    expect(first, startsWith('preview-comic-'));
    expect(first, isNot(equals(different)));
  });

  test('metadataItemFromPreview maps preview fields', () {
    const service = LibraryAddWorkflowService();
    const preview = AdminProviderPreview(
      provider: 'gcd',
      providerItemId: '123',
      kind: 'comic',
      title: 'Example',
    );

    final item = service.metadataItemFromPreview(preview);

    expect(item, isA<CatalogItem>());
    expect(item.id, startsWith('preview-comic-'));
    expect(item.kind, 'comic');
    expect(item.title, 'Example');
  });

  test('metadataItemFromPreview delegates kind payload decoding', () {
    const service = LibraryAddWorkflowService();
    final preview = AdminProviderPreview(
      provider: 'gcd',
      providerItemId: '123',
      kind: 'comic',
      title: 'Example',
      itemNumber: '1',
      publisher: 'Example Comics',
      series: const CatalogSeriesDetailsDto(seriesTitle: 'Example Series'),
      genres: const ['superhero'],
    );

    final item = service.metadataItemFromPreview(preview);

    expect(item.toSyncPayload()['item_number'], '1');
    expect(item.toSyncPayload()['publisher'], 'Example Comics');
    expect(item.toSyncPayload()['series_title'], 'Example Series');
    expect(item.toSyncPayload()['genres'], ['superhero']);
  });
}

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('variant target without IDs falls back to the work reference', () {
    final item = _item();
    expect(
        item.catalogRefForAnchor(anchorType: 'variant'),
        const CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId('work'),
          id: 'comic-1',
        ));
  });

  test('variant target with only an edition ID resolves to the edition', () {
    final target = _item().catalogRefForAnchor(
      anchorType: 'variant',
      editionId: 'edition-1',
    );

    expect(target.entityType.apiValue, 'edition');
    expect(target.id, 'edition-1');
  });

  test('anchor type accepts only canonical schema values', () {
    final item = _item();
    expect(item.catalogRefForAnchor(anchorType: 'physical-release').entityType,
        const CatalogEntityTypeId('work'));
    expect(item.catalogRefForAnchor(anchorType: 'bundle-release').entityType,
        const CatalogEntityTypeId('work'));
    expect(item.catalogRefForAnchor(anchorType: 'release').entityType,
        const CatalogEntityTypeId('work'));
  });
}

CatalogItemDto _item() => CatalogItemDto.raw(
      id: 'comic-1',
      mediaKind: CatalogMediaKind.comic,
      common: const CatalogCommonDto(title: 'Comic'),
      payload: const <String, dynamic>{},
    );

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog items expose a typed work reference', () {
    expect(
      _item().catalogRef,
      const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId('work'),
        id: 'comic-1',
      ),
    );
  });

  test('catalog target selection preserves typed hierarchy references', () {
    final item = _item();
    const release = CatalogEntityRef(
      kind: CatalogMediaKind.comic,
      entityType: CatalogEntityTypeId('release'),
      id: 'release-1',
      rootId: 'comic-1',
      parentId: 'edition-1',
    );

    expect(item.catalogRefForTarget(release), release);
  });

  test('catalog entity references are usable as typed map keys', () {
    final ref = _item().catalogRef;
    final values = <CatalogEntityRef, String>{ref: 'comic'};

    expect(values[ref], 'comic');
    expect(
      values[const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId('work'),
        id: 'comic-1',
      )],
      'comic',
    );
  });
}

CatalogItemDto _item() => CatalogItemDto.raw(
      id: 'comic-1',
      mediaKind: CatalogMediaKind.comic,
      common: const CatalogCommonDto(title: 'Comic'),
      payload: const <String, dynamic>{},
    );

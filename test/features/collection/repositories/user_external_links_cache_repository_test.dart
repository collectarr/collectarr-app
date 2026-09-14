import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late UserExternalLinksCacheRepository repo;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repo = UserExternalLinksCacheRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('replaceForCatalogRef stores and reloads user links', () async {
    final links = [
      UserExternalLink(
        id: 'link-1',
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.movie,
          entityType: CatalogEntityTypeId('work'),
          id: 'item-1',
        ),
        label: 'Review',
        url: 'https://example.com/review',
        kind: 'review',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
      ),
      UserExternalLink(
        id: 'link-2',
        catalogRef: const CatalogEntityRef(
          kind: CatalogMediaKind.movie,
          entityType: CatalogEntityTypeId('work'),
          id: 'item-1',
        ),
        label: 'Trailer',
        url: 'https://example.com/trailer',
        kind: 'trailer',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
      ),
    ];

    const catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.movie,
      entityType: CatalogEntityTypeId('work'),
      id: 'item-1',
    );
    await repo.replaceForCatalogRef(catalogRef, links);

    final loaded = await repo.listByCatalogRef(catalogRef);
    expect(loaded, hasLength(2));
    expect(loaded.map((link) => link.kind), ['review', 'trailer']);
    expect(loaded.last.label, 'Trailer');
  });

  test('does not replace a sibling target with the same id', () async {
    const catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.book,
      entityType: CatalogEntityTypeId('edition'),
      id: 'edition-1',
      rootId: 'book-1',
    );
    const siblingRef = CatalogEntityRef(
      kind: CatalogMediaKind.book,
      entityType: CatalogEntityTypeId('edition'),
      id: 'edition-1',
      rootId: 'book-2',
    );
    final sibling = UserExternalLink(
      id: 'sibling-link',
      catalogRef: siblingRef,
      label: 'Sibling',
      url: 'https://example.test/sibling',
      kind: 'reference',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    await repo.replaceForCatalogRef(siblingRef, [sibling]);
    await repo.replaceForCatalogRef(
      catalogRef,
      [
        UserExternalLink(
          id: 'primary-link',
          catalogRef: catalogRef,
          label: 'Primary',
          url: 'https://example.test/primary',
          kind: 'reference',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ],
    );

    expect((await repo.listByCatalogRef(siblingRef)).single.id, 'sibling-link');
    expect((await repo.listByCatalogRef(catalogRef)).single.id, 'primary-link');
  });
}

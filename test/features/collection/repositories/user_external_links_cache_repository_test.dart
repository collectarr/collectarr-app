import 'package:collectarr_app/core/db/local_database.dart';
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

  test('replaceForItem stores and reloads user links', () async {
    final links = [
      UserExternalLink(
        id: 'link-1',
        itemId: 'item-1',
        label: 'Review',
        url: 'https://example.com/review',
        kind: 'review',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
      ),
      UserExternalLink(
        id: 'link-2',
        itemId: 'item-1',
        label: 'Trailer',
        url: 'https://example.com/trailer',
        kind: 'trailer',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
      ),
    ];

    await repo.replaceForItem('item-1', links);

    final loaded = await repo.listByItemId('item-1');
    expect(loaded, hasLength(2));
    expect(loaded.map((link) => link.kind), ['review', 'trailer']);
    expect(loaded.last.label, 'Trailer');
  });
}

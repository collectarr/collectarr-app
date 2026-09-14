import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/data/remote/book_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late BookRepository repository;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repository = BookRepository(db);
  });

  tearDown(() => db.close());

  test('persists and retrieves typed Book media and editions', () async {
    const media = BookMedia(
      id: BookMediaId('book-1'),
      title: 'The Left Hand of Darkness',
      sortTitle: 'Left Hand of Darkness, The',
      editions: [
        BookRelease(
          id: 'edition-1',
          title: 'Paperback Edition',
          workId: 'book-1',
          physicalFormat: 'paperback',
        ),
      ],
    );

    await repository.updateMedia(media);
    final loaded = await repository.getMedia(const BookMediaId('book-1'));

    expect(loaded?.id, media.id);
    expect(loaded?.title, media.title);
    expect(loaded?.sortTitle, media.sortTitle);
    expect(loaded?.editions.single.typedId, const BookReleaseId('edition-1'));
    expect(loaded?.editions.single.physicalFormat, 'paperback');
    expect(
      await repository.getRelease(
        const BookMediaId('book-1'),
        const BookReleaseId('edition-1'),
      ),
      isNotNull,
    );
  });

  test('searches typed Book media deterministically', () async {
    await repository.updateMedia(
      const BookMedia(id: BookMediaId('book-2'), title: 'Batman: Book Edition'),
    );
    await repository.updateMedia(
      const BookMedia(
        id: BookMediaId('book-1'),
        title: 'Vagabond',
        sortTitle: 'Vagabond',
      ),
    );

    expect(
      (await repository.search()).map((media) => media.id),
      [const BookMediaId('book-2'), const BookMediaId('book-1')],
    );
    expect(
      (await repository.search('gabon')).map((media) => media.title),
      ['Vagabond'],
    );
  });

  test('falls back to the typed remote source on a local miss', () async {
    final remote = _FakeBookRemoteSource(
      (id) async => BookMedia(id: id, title: 'Fetched Book'),
    );
    final remoteRepository = BookRepository(db, remote: remote);

    final loaded =
        await remoteRepository.getMedia(const BookMediaId('book-remote'));
    final cached = await repository.getMedia(const BookMediaId('book-remote'));

    expect(loaded?.title, 'Fetched Book');
    expect(cached?.title, 'Fetched Book');
    expect(remote.requestedIds, [const BookMediaId('book-remote')]);
  });

  test('returns null for a missing media without a remote source', () async {
    expect(await repository.getMedia(const BookMediaId('missing')), isNull);
    expect(
      () => repository.updateMedia(
        const BookMedia(id: BookMediaId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
  });
}

final class _FakeBookRemoteSource implements BookRemoteSource {
  _FakeBookRemoteSource(this._fetch);

  final Future<BookMedia> Function(BookMediaId id) _fetch;
  final requestedIds = <BookMediaId>[];

  @override
  Future<BookMedia> fetchMedia(BookMediaId id) {
    requestedIds.add(id);
    return _fetch(id);
  }
}

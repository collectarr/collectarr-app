import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:collectarr_app/features/library/kinds/anime/barcode/anime_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/barcode/boardgame_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/book/barcode/book_isbn_resolver.dart';
import 'package:collectarr_app/features/library/kinds/comic/barcode/comic_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/game/barcode/game_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/manga/barcode/manga_identifier_resolver.dart';
import 'package:collectarr_app/features/library/kinds/movie/barcode/movie_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/music/barcode/music_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/tv/barcode/tv_barcode_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const retailCode = ScannedCode(
    rawValue: '012345678905',
    value: '012345678905',
    symbology: ScannedCodeSymbology.upcA,
  );
  const isbn13 = ScannedCode(
    rawValue: '9780306406157',
    value: '9780306406157',
    symbology: ScannedCodeSymbology.ean13,
  );
  const invalidCode = ScannedCode(
    rawValue: 'not-a-code',
    value: 'NOTACODE',
    symbology: ScannedCodeSymbology.unknown,
  );

  test('all kind retail resolvers accept valid retail codes', () {
    final resolvers = <String? Function(ScannedCode)>[
      const AnimeBarcodeResolver().resolve,
      const BoardGameBarcodeResolver().resolve,
      const ComicBarcodeResolver().resolve,
      const GameBarcodeResolver().resolve,
      const MovieBarcodeResolver().resolve,
      const MusicBarcodeResolver().resolve,
      const TvBarcodeResolver().resolve,
    ];

    for (final resolve in resolvers) {
      expect(resolve(retailCode), retailCode.value);
      expect(resolve(invalidCode), isNull);
    }
  });

  test('Book and Manga resolvers accept valid ISBN and reject invalid data',
      () {
    expect(const BookIsbnResolver().resolve(isbn13), isbn13.value);
    expect(const MangaIdentifierResolver().resolve(isbn13), isbn13.value);
    expect(const BookIsbnResolver().resolve(retailCode), isNull);
    expect(const MangaIdentifierResolver().resolve(invalidCode), isNull);
  });
}

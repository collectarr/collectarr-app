import 'package:collectarr_app/features/library/kinds/game_hardware/entries/game_hardware_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/entries/game_hardware_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/entries/game_toy_entry_details_codec.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_codec.dart';

/// Test-only adapter for executing the same serialization contract against
/// concrete kind codecs. Production code does not use a common details codec.
abstract interface class EntryDetailsTestFixture {
  JsonEncodable fromJson(JsonMap json);

  JsonEncodable defaultDetails();

  void validate(JsonEncodable details);
}

final class _TypedEntryDetailsTestFixture<TDetails extends JsonEncodable>
    implements EntryDetailsTestFixture {
  const _TypedEntryDetailsTestFixture({
    required this.decode,
    required this.defaults,
  });

  final TDetails Function(JsonMap json) decode;
  final TDetails Function() defaults;

  @override
  TDetails fromJson(JsonMap json) => decode(json);

  @override
  TDetails defaultDetails() => defaults();

  @override
  void validate(JsonEncodable details) {
    if (details is! TDetails) {
      throw ArgumentError(
        'Invalid entry details type "${details.runtimeType}". '
        'Expected "$TDetails".',
      );
    }
  }
}

EntryDetailsTestFixture entryDetailsFixtureForTest(CatalogMediaKind kind) {
  return switch (kind) {
    CatalogMediaKind.boardgame =>
      _TypedEntryDetailsTestFixture<BoardgameEntryDetails>(
        decode: const BoardgameEntryDetailsCodec().fromJson,
        defaults: const BoardgameEntryDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.book => _TypedEntryDetailsTestFixture<BookEntryDetails>(
        decode: const BookEntryDetailsCodec().fromJson,
        defaults: const BookEntryDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.comic => _TypedEntryDetailsTestFixture<ComicEntryDetails>(
        decode: const ComicEntryDetailsCodec().fromJson,
        defaults: const ComicEntryDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.game => _TypedEntryDetailsTestFixture<GameEntryDetails>(
        decode: const GameEntryDetailsCodec().fromJson,
        defaults: const GameEntryDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.gameHardware =>
      _TypedEntryDetailsTestFixture<GameHardwareEntryDetails>(
        decode: const GameHardwareEntryDetailsCodec().fromJson,
        defaults: const GameHardwareEntryDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.gameToy =>
      _TypedEntryDetailsTestFixture<GameToyEntryDetails>(
        decode: const GameToyEntryDetailsCodec().fromJson,
        defaults: const GameToyEntryDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.movie => _TypedEntryDetailsTestFixture<MovieEntryDetails>(
        decode: const MovieEntryDetailsCodec().fromJson,
        defaults: const MovieEntryDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.music => _TypedEntryDetailsTestFixture<MusicEntryDetails>(
        decode: const MusicEntryDetailsCodec().fromJson,
        defaults: const MusicEntryDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.unknown =>
      throw ArgumentError('No concrete Entry details fixture for kind: $kind'),
  };
}

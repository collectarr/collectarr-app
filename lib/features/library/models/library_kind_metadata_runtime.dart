import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

abstract interface class LibraryKindMetadataRuntime {
  CatalogMediaKind get mediaKind;
  Map<String, dynamic> toSyncPayload();
}

typedef KindMetadataDecoder = LibraryKindMetadataRuntime Function(
  CatalogMediaKind mediaKind,
  Map<String, dynamic> json,
);

abstract final class LibraryKindMetadataDecoders {
  static KindMetadataDecoder? _globalDecoder;

  static void registerGlobalDecoder(KindMetadataDecoder decoder) {
    _globalDecoder = decoder;
  }

  static LibraryKindMetadataRuntime decode(
    CatalogMediaKind mediaKind,
    Map<String, dynamic> json,
  ) {
    final decoder = _globalDecoder;
    if (decoder != null) {
      return decoder(mediaKind, json);
    }
    return _builtinDecode(mediaKind, json);
  }

  static LibraryKindMetadataRuntime _builtinDecode(
    CatalogMediaKind mediaKind,
    Map<String, dynamic> json,
  ) {
    switch (mediaKind) {
      case CatalogMediaKind.comic:
        return ComicCatalogMetadata.fromJson(json);
      case CatalogMediaKind.book:
        return BookCatalogMetadata.fromJson(json);
      case CatalogMediaKind.music:
        return MusicCatalogMetadata.fromJson(json);
      case CatalogMediaKind.movie:
        return MovieCatalogMetadata.fromJson(json);
      case CatalogMediaKind.tv:
        return TvSeriesMetadata.fromJson(json);
      case CatalogMediaKind.game:
        return GameCatalogMetadata.fromJson(json);
      case CatalogMediaKind.boardgame:
        return BoardGameMetadata.fromJson(json);
      case CatalogMediaKind.manga:
        return MangaMetadata.fromJson(json);
      case CatalogMediaKind.anime:
        return AnimeMetadata.fromJson(json);
      case CatalogMediaKind.unknown:
        return DefaultMapKindMetadata(mediaKind, json);
    }
  }
}

class DefaultMapKindMetadata implements LibraryKindMetadataRuntime {
  const DefaultMapKindMetadata(this.mediaKind, this._payload);

  @override
  final CatalogMediaKind mediaKind;

  final Map<String, dynamic> _payload;

  @override
  Map<String, dynamic> toSyncPayload() => _payload;
}

class EmptyKindMetadata implements LibraryKindMetadataRuntime {
  const EmptyKindMetadata(this.mediaKind);

  @override
  final CatalogMediaKind mediaKind;

  @override
  Map<String, dynamic> toSyncPayload() => const {};
}

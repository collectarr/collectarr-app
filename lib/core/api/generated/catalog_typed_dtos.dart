// Transitional compatibility shim for legacy typed DTO imports.
import 'collectarr_api.models.dart';

export 'collectarr_api.models.dart';

typedef CatalogTypedDto = TypedMetadataResponse;
typedef BookWorkDto = BookWorkV1Response;
typedef BookEditionDto = BookEditionV1Response;
typedef GameWorkDto = GameWorkV1Response;
typedef GameReleaseDto = GameReleaseV1Response;
typedef BoardGameWorkDto = BoardGameWorkV1Response;
typedef BoardGameEditionDto = BoardGameEditionV1Response;
typedef MusicReleaseDto = MusicReleaseV1Response;
typedef MusicMediaDto = MusicMediaV1Response;
typedef MusicTrackDto = MusicTrackV1Response;
typedef ComicWorkDto = ComicWorkV1Response;
typedef MangaWorkDto = MangaWorkV1Response;
typedef AnimeSeriesDto = AnimeSeriesV1Response;
typedef MovieWorkDto = MovieWorkV1Response;
typedef TvSeriesDto = TVSeriesV1Response;

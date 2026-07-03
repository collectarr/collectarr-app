// Transitional compatibility shim for legacy typed DTO imports.
import 'collectarr_api.models.dart';

export 'collectarr_api.models.dart';

typedef CatalogTypedDto = TypedMetadataResponse;
typedef BookWorkV1Response = BookWorkDto;
typedef BookEditionV1Response = BookEditionDto;
typedef GameWorkV1Response = GameWorkDto;
typedef GameReleaseV1Response = GameReleaseDto;
typedef BoardGameWorkV1Response = BoardGameWorkDto;
typedef BoardGameEditionV1Response = BoardGameEditionDto;
typedef MusicReleaseV1Response = MusicReleaseDto;
typedef MusicMediaV1Response = MusicMediaDto;
typedef MusicTrackV1Response = MusicTrackDto;
typedef ComicWorkV1Response = ComicWorkDto;
typedef MangaWorkV1Response = MangaWorkDto;
typedef AnimeSeriesV1Response = AnimeSeriesDto;
typedef MovieWorkV1Response = MovieWorkDto;
typedef TVSeriesV1Response = TvSeriesDto;

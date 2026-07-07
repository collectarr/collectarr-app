import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_domain.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

AnimeSeries animeSeriesFromDto(AnimeSeriesDto dto) => AnimeSeries.fromDto(dto);

AnimeSeries animeSeriesFromMetadataItem(LibraryMetadataItem item) =>
    AnimeSeries.fromMetadataItem(item);

AnimePersonalOverlay animePersonalOverlayFromShelf(ShelfEntry source) =>
    AnimePersonalOverlay.fromShelf(source);

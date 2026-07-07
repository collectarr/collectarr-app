import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';

ComicWork comicWorkFromDto(ComicWorkDto dto) => ComicWork.fromDto(dto);

ComicWork comicWorkFromMetadataItem(ShelfEntry source) =>
    ComicWork.fromMetadataItem(source.catalogItem!);

ComicPersonalOverlay comicPersonalOverlayFromShelf(ShelfEntry source) =>
    ComicPersonalOverlay.fromShelf(source);

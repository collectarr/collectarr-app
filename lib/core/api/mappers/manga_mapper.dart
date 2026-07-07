import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_domain.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

MangaWork mangaWorkFromDto(MangaWorkDto dto) => MangaWork.fromDto(dto);

MangaWork mangaWorkFromMetadataItem(LibraryMetadataItem item) =>
    MangaWork.fromMetadataItem(item);

MangaPersonalOverlay mangaPersonalOverlayFromShelf(ShelfEntry source) =>
    MangaPersonalOverlay.fromShelf(source);

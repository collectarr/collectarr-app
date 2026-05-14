import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';

bool comicItemHasMissingCover(CatalogItem item) {
  return !_hasText(item.displayCoverUrl);
}

bool comicItemHasMissingDetails(CatalogItem item) {
  return !_hasText(item.publisher) ||
      item.releaseDate == null ||
      !_hasText(item.synopsis);
}

bool comicEntryHasMissingMetadata(ShelfEntry entry) {
  final item = entry.catalogItem;
  return item == null ||
      comicItemHasMissingCover(item) ||
      comicItemHasMissingDetails(item);
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

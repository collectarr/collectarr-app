import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';

export 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
export 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
export 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
export 'package:collectarr_app/features/library/kinds/book/data/book_entry_repository.dart';
export 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
export 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_codec.dart';
export 'package:collectarr_app/features/library/kinds/book/add/book_add_draft.dart';
export 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace.dart';
export 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';

final class BookPersonalOverlay {
  const BookPersonalOverlay({
    this.libraryEntry,
    this.trackingSummary,
    this.wishlistItem,
    this.locationPath,
    this.updatedAt,
  });

  factory BookPersonalOverlay.fromShelf(LibraryWorkspaceSource source) {
    return BookPersonalOverlay(
      libraryEntry: BookLibraryEntryProjection.fromDispatch(
        source.libraryEntryDispatch,
      ),
      trackingSummary: source.trackingSummary,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      updatedAt: source.updatedAt,
    );
  }

  final BookLibraryEntry? libraryEntry;
  final TrackingSummary? trackingSummary;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final DateTime? updatedAt;
}

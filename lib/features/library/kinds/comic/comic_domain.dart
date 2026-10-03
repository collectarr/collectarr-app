import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
export 'package:collectarr_app/features/library/domain/valuation_snapshot.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
export 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
export 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
export 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';
export 'package:collectarr_app/features/library/kinds/comic/data/local/comic_local_mapper.dart';
export 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
export 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
export 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_codec.dart';
export 'package:collectarr_app/features/library/kinds/comic/add/comic_add_draft.dart';
export 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';
export 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace.dart';
export 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';

final class ComicPersonalOverlay {
  const ComicPersonalOverlay({
    this.libraryEntry,
    this.trackingSummary,
    this.wishlistItem,
    this.locationPath,
    this.lastBagBoardDate,
    this.signedBy,
    this.updatedAt,
  });

  factory ComicPersonalOverlay.fromShelf(LibraryWorkspaceSource source) {
    final libraryEntry =
        ComicLibraryEntryProjection.fromDispatch(source.libraryEntryDispatch);
    return ComicPersonalOverlay(
      libraryEntry: libraryEntry,
      trackingSummary: source.trackingSummary,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      lastBagBoardDate: libraryEntry?.details.lastBagBoardDate,
      signedBy: libraryEntry?.details.signedBy,
      updatedAt: source.updatedAt,
    );
  }

  final ComicLibraryEntry? libraryEntry;
  final TrackingSummary? trackingSummary;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final DateTime? lastBagBoardDate;
  final String? signedBy;
  final DateTime? updatedAt;

  ComicEntryDetails? get _comicDetails => libraryEntry?.details;

  bool get isSlabbed => _comicDetails?.rawOrSlabbed == 'Slabbed';
  bool get keyComic => _comicDetails?.keyComic ?? false;
  String? get gradingCompany => _comicDetails?.gradingCompany;
}

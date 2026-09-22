import 'package:collectarr_app/core/api/dto/catalog/catalog_common_dto.dart';
import 'package:collectarr_app/core/models/catalog_edit_metadata.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';

/// Work-facing semantic edit operations used by the shared shell.
abstract interface class LibraryWorkEditSession {
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryCanonicalEditValues values,
  );

  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection);

  void setExternalLinks(List<TrailerLinkDto> links);
}

/// Canonical Work/Release values collected by the form shell and interpreted
/// only by the selected kind-owned edit session.
final class LibraryCanonicalEditValues {
  const LibraryCanonicalEditValues({
    required this.title,
    this.displayTitle,
    this.sortKey,
    this.originalTitle,
    this.localizedTitle,
    this.searchAliases,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final String title;
  final String? displayTitle;
  final String? sortKey;
  final String? originalTitle;
  final String? localizedTitle;
  final List<String>? searchAliases;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;

  factory LibraryCanonicalEditValues.fromMetadata(
      CatalogEditMetadata metadata) {
    return LibraryCanonicalEditValues(
      title: metadata.title,
      displayTitle: metadata.displayTitle,
      sortKey: metadata.sortKey,
      originalTitle: metadata.originalTitle,
      localizedTitle: metadata.localizedTitle,
      searchAliases: metadata.searchAliases,
      synopsis: metadata.synopsis,
      coverImageUrl: metadata.coverImageUrl,
      thumbnailImageUrl: metadata.thumbnailImageUrl,
    );
  }

  Map<String, Object?> toFields() => {
        'title': title,
        'display_title': displayTitle,
        'sort_key': sortKey,
        'original_title': originalTitle,
        'localized_title': localizedTitle,
        'search_aliases': searchAliases,
        'synopsis': synopsis,
        'cover_image_url': coverImageUrl,
        'thumbnail_image_url': thumbnailImageUrl,
      };
}

/// Release-facing semantic edit operations. Work and Release currently share
/// the same selection mutation shape, but remain separate contracts so the
/// generic shell cannot accidentally treat a release as a work aggregate.
abstract interface class LibraryReleaseEditSession
    implements LibraryWorkEditSession {}

/// Copy-facing semantic edit operations used by the shared shell.
abstract interface class LibraryCopyEditSession {
  JsonEncodable toDetailsDraft();

  void initializePersonalState(PersonalStateDraft personal);

  OwnedItemUpdatePayload buildOwnedUpdatePayload({
    required OwnedItemRef ownedRef,
    required PersonalStateDraft personal,
  });
}

/// Default Work/Release behavior for a kind-owned session that does not need
/// extra selection or external-link handling.
mixin LibraryWorkEditSessionDefaults implements LibraryWorkEditSession {
  @override
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryCanonicalEditValues values,
  ) {
    return selection.copyWith(
      kindItem: selection.kindItem.copyWith(
        title: values.title,
        displayTitle: values.displayTitle,
        sortKey: values.sortKey,
        originalTitle: values.originalTitle,
        localizedTitle: values.localizedTitle,
        searchAliases: values.searchAliases,
        synopsis: values.synopsis,
        coverImageUrl: values.coverImageUrl,
        thumbnailImageUrl: values.thumbnailImageUrl,
      ),
      canonicalFields: values.toFields(),
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) =>
      selection;

  @override
  void setExternalLinks(List<TrailerLinkDto> links) {}
}

/// Default Copy initialization for a kind-owned session with no personal
/// details beyond the shared form state.
mixin LibraryCopyEditSessionDefaults implements LibraryCopyEditSession {
  @override
  void initializePersonalState(PersonalStateDraft personal) {}
}

/// The kind-owned edit composition returned to the generic UI shell.
///
/// The implementations may currently be backed by one concrete object, but
/// the public contract is explicitly split by entity scope. The generic shell
/// never receives a semantic aggregate session.
final class LibraryEditSessionBundle {
  const LibraryEditSessionBundle({
    required this.workSession,
    required this.releaseSession,
    required this.copySession,
    required this.disposeSession,
  });

  final LibraryWorkEditSession workSession;
  final LibraryReleaseEditSession releaseSession;
  final LibraryCopyEditSession copySession;
  final void Function() disposeSession;
}

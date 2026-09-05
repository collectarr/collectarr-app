import 'package:collectarr_app/core/api/dto/catalog/catalog_common_dto.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';

/// Abstract domain interface for kind-specific edit drafts.
abstract class LibraryEditKindDraft {
  const LibraryEditKindDraft();

  OwnedDetailsDraft toDetailsDraft();

  /// Allows kind-specific drafts to enrich the emitted selection during submit if needed.
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) =>
      selection;

  /// Informs kind-specific draft of external links configured in UI.
  void setExternalLinks(List<TrailerLinkDto> links) {}

  /// Optional dispose callback for controllers owned by this draft.
  void dispose() {}
}

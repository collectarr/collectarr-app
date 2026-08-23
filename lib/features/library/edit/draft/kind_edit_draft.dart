import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

/// Abstract domain interface for kind-specific edit drafts.
abstract class KindEditDraft {
  const KindEditDraft();

  OwnedDetailsDraft toDetailsDraft();

  /// Allows kind-specific drafts to enrich the emitted selection during submit if needed.
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) =>
      selection;

  /// Optional dispose callback for controllers owned by this draft.
  void dispose() {}
}

class GenericEditDraft extends KindEditDraft {
  const GenericEditDraft();

  @override
  OwnedDetailsDraft toDetailsDraft() => const GenericOwnedDetailsDraft();
}

KindEditDraft createGenericEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) =>
    const GenericEditDraft();

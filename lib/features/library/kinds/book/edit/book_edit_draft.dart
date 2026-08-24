import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class BookEditDraft extends KindEditDraft {
  BookEditDraft({
    this.signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
  });

  String? signedBy;
  bool dustJacketPresent;
  String? dustJacketCondition;

  @override
  OwnedDetailsDraft toDetailsDraft() => BookOwnedDetailsDraft(
        signedBy: signedBy,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
      );

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    if (selection.personal != null) {
      return selection.copyWith(
        personal: selection.personal!.copyWith(
          signedBy: signedBy,
        ),
      );
    }
    return selection;
  }
}

KindEditDraft createBookEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final book = ownedItem?.bookDetails;
  final comic = ownedItem?.comicDetails;
  return BookEditDraft(
    signedBy: book?.signedBy ?? comic?.signedBy,
    dustJacketPresent: book?.dustJacketPresent ?? false,
    dustJacketCondition: book?.dustJacketCondition,
  );
}

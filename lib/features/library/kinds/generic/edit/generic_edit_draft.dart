import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';

class GenericEditDraft extends LibraryEditKindDraft {
  const GenericEditDraft();

  @override
  OwnedDetailsDraft toDetailsDraft() => const GenericOwnedDetailsDraft();
}

LibraryEditKindDraft createGenericEditDraft({
  required CatalogItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) =>
    const GenericEditDraft();

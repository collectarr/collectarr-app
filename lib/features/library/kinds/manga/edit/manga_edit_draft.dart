import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';

class MangaEditDraft extends KindEditDraft {
  MangaEditDraft({
    this.signedBy,
    this.obiStripPresent = false,
    this.slipcoverPresent = false,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    this.boxSetOuterCondition,
    this.insertsPresent = false,
    this.printing,
    this.localizedEdition,
    required this.pageCountController,
    required this.imprintController,
  });

  String? signedBy;
  bool obiStripPresent;
  bool slipcoverPresent;
  bool dustJacketPresent;
  String? dustJacketCondition;
  String? boxSetOuterCondition;
  bool insertsPresent;
  String? printing;
  String? localizedEdition;
  final TextEditingController pageCountController;
  final TextEditingController imprintController;

  @override
  OwnedDetailsDraft toDetailsDraft() => MangaOwnedDetailsDraft(
        signedBy: signedBy,
        obiStripPresent: obiStripPresent,
        slipcoverPresent: slipcoverPresent,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
        boxSetOuterCondition: boxSetOuterCondition,
        insertsPresent: insertsPresent,
        printing: printing,
        localizedEdition: localizedEdition,
      );

  @override
  void dispose() {
    pageCountController.dispose();
    imprintController.dispose();
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final payload = selection.item.kindMetadata.toSyncPayload();
    final updatedPayload = {
      ...payload,
      if (int.tryParse(pageCountController.text) != null)
        'page_count': int.tryParse(pageCountController.text),
      if (emptyToNull(imprintController.text) != null)
        'imprint': emptyToNull(imprintController.text),
      if (dustJacketPresent) 'dust_jacket': true,
      if (dustJacketCondition != null)
        'dust_jacket_condition': dustJacketCondition,
    };
    final updatedItem = selection.item.copyWith(
      kindMetadata: LibraryKindMetadataDecoders.decode(
        selection.item.mediaKind,
        updatedPayload,
      ),
    );
    var result = selection.copyWith(item: updatedItem);
    if (result.personal != null) {
      result = result.copyWith(
        personal: result.personal!.copyWith(
          signedBy: signedBy,
        ),
      );
    }
    return result;
  }
}

KindEditDraft createMangaEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final manga = ownedItem?.mangaDetails;
  final metadata = item.kindMetadata;
  if (metadata is! MangaMetadata) {
    throw ArgumentError.value(
      metadata,
      'item.kindMetadata',
      'Expected MangaMetadata',
    );
  }
  return MangaEditDraft(
    signedBy: manga?.signedBy,
    obiStripPresent: manga?.obiStripPresent ?? false,
    slipcoverPresent: manga?.slipcoverPresent ?? false,
    dustJacketPresent: manga?.dustJacketPresent ?? false,
    dustJacketCondition: manga?.dustJacketCondition,
    boxSetOuterCondition: manga?.boxSetOuterCondition,
    insertsPresent: manga?.insertsPresent ?? false,
    printing: manga?.printing,
    localizedEdition: manga?.localizedEdition,
    pageCountController: textControllers.create(
      text: metadata.pageCount?.toString() ?? '',
    ),
    imprintController: textControllers.create(
      text: metadata.imprint ?? '',
    ),
  );
}

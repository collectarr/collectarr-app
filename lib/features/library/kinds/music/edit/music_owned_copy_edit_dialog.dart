import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_copy_media_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

Widget buildMusicOwnedCopyLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _MusicOwnedCopyEditDialog(request: request);

final class _MusicOwnedCopyEditDialog extends StatefulWidget {
  const _MusicOwnedCopyEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_MusicOwnedCopyEditDialog> createState() =>
      _MusicOwnedCopyEditDialogState();
}

final class _MusicOwnedCopyEditDialogState
    extends State<_MusicOwnedCopyEditDialog> {
  late final MusicOwnedItem _copy;
  late final MusicRelease _release;
  late final MusicOwnedEditDraft _draft;
  List<ItemImageEdit> _imageEdits = const [];

  @override
  void initState() {
    super.initState();
    final node = widget.request.node;
    if (node is! LibraryCopyRef) {
      throw StateError('Music Copy Edit requires an exact copy reference');
    }
    final copy = MusicOwnedItemProjection.fromDispatch(
      widget.request.ownedItemDispatch,
    );
    if (copy == null ||
        (node.copyId != null && copy.id.value != node.copyId) ||
        widget.request.ownedItemDispatch?.ref != node.ownedRef ||
        node.ownedRef.id.value != copy.id.value) {
      throw StateError('The selected Music copy is unavailable or stale');
    }
    final transport = widget.request.kindItem.toTransport();
    final raw = transport.kindMetadata;
    final group = raw is MusicReleaseGroup
        ? raw
        : MusicReleaseGroup.fromJson(transport.payload);
    MusicRelease? selectedRelease;
    for (final release in group.releases) {
      if (release.id.value == node.releaseId) {
        selectedRelease = release;
        break;
      }
    }
    if (selectedRelease == null ||
        copy.releaseRef.id != node.releaseId ||
        copy.releaseRef.rootScope.id != node.workId) {
      throw StateError(
          'The Music copy does not belong to the selected release');
    }
    _copy = copy;
    _release = selectedRelease;
    _draft = MusicOwnedEditDraft.fromItem(copy);
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<MusicOwnedItem, MusicOwnedEditDraft>(
        schema: musicOwnedEditSchema,
        model: _copy,
        draft: _draft,
        title: 'Edit copy - ${_release.title}',
        icon: Icons.library_music_outlined,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_music_copy',
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        extraTabs: [
          EditSchemaExtraTab(
            label: 'Disc details',
            icon: Icons.album_outlined,
            content: MusicOwnedCopyMediaTab(
              draft: _draft,
              mediums: _release.mediums,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'My Images',
            icon: Icons.photo_library_outlined,
            content: ItemImagesEditSection(
              images: widget.request.itemImages,
              accent: widget.request.accent,
              onChanged: (edits) => _imageEdits = edits,
            ),
          ),
        ],
        onSave: (_) {
          final details = _draft.toDetailsDraft();
          final payload = MusicOwnedItemUpdatePayload.partial(
            targetRef: Patch.set(_copy.releaseRef),
            quantity: Patch.set(_draft.quantity),
            condition: Patch.set(_nullable(_draft.condition)),
            grade: Patch.set(_nullable(_draft.grade)),
            purchaseDate: Patch.set(_draft.purchaseDate),
            pricePaidCents: Patch.set(_draft.pricePaidCents),
            currency: Patch.set(_nullable(_draft.currency)),
            personalNotes: Patch.set(_nullable(_draft.personalNotes)),
            locationId: Patch.set(_nullable(_draft.locationId)),
            purchaseStore: Patch.set(_nullable(_draft.purchaseStore)),
            collectionStatus: Patch.set(_nullable(_draft.collectionStatus)),
            isDigital: Patch.set(_draft.isDigital),
            tags: Patch.set(_nullable(_draft.tags)),
            soldAt: Patch.set(_draft.soldAt),
            sellPriceCents: Patch.set(_draft.sellPriceCents),
            soldTo: Patch.set(_nullable(_draft.soldTo)),
            marketValueCents: Patch.set(_draft.marketValueCents),
            indexNumber: Patch.set(_draft.indexNumber),
            details: Patch.set(details),
            ownerLabel: Patch.set(_nullable(_draft.ownerLabel)),
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              item: widget.request.item,
              kindItem: widget.request.kindItem,
              personal: LibraryPersonalEditSelection(
                targetRef: _copy.releaseRef,
                condition: _nullable(_draft.condition),
                purchaseDate: _draft.purchaseDate,
                pricePaidCents: _draft.pricePaidCents,
                currency: _nullable(_draft.currency),
                personalNotes: _nullable(_draft.personalNotes),
                quantity: _draft.quantity,
                indexNumber: _draft.indexNumber,
                locationId: _draft.locationId,
                tags: _nullable(_draft.tags),
                soldAt: _draft.soldAt,
                sellPriceCents: _draft.sellPriceCents,
                soldTo: _nullable(_draft.soldTo),
                purchaseStore: _nullable(_draft.purchaseStore),
                collectionStatus: _nullable(_draft.collectionStatus),
                marketValueCents: _draft.marketValueCents,
                ownerLabel: _nullable(_draft.ownerLabel),
              ),
              scope: LibraryEntityScope.copy,
              ownedUpdatePayload: payload,
              itemImageEdits: _imageEdits,
            ),
          );
        },
      );
}

String? _nullable(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

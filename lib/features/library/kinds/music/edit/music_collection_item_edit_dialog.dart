import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/collection/commands/collection_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_collection_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_collection_item_media_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_header_title.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_collection_item_update_payload.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

Widget buildMusicCollectionItemLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _MusicCollectionItemEditDialog(request: request);

final class _MusicCollectionItemEditDialog extends StatefulWidget {
  const _MusicCollectionItemEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_MusicCollectionItemEditDialog> createState() =>
      _MusicCollectionItemEditDialogState();
}

final class _MusicCollectionItemEditDialogState
    extends State<_MusicCollectionItemEditDialog> {
  late final MusicCollectionItem _copy;
  late final MusicAlbum _album;
  late final MusicOwnedEditDraft _draft;
  List<ItemImageEdit> _imageEdits = const [];

  @override
  void initState() {
    super.initState();
    final node = widget.request.node;
    if (node is! LibraryCollectionItemNodeRef) {
      throw StateError('Music Copy Edit requires an exact copy reference');
    }
    final copy = MusicCollectionItemProjection.fromDispatch(
      widget.request.collectionItemDispatch,
    );
    if (copy == null ||
        widget.request.collectionItemDispatch?.ref != node.collectionItemRef ||
        node.collectionItemRef.id.value != copy.id.value) {
      throw StateError('The selected Music copy is unavailable or stale');
    }
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    final album = MusicCatalogMapper.mapMetadataItemToMusic(transport);
    if (copy.catalogRef.rootScope.id != node.catalogItemId ||
        copy.catalogRef != widget.request.kindItem.reference.rootScope) {
      throw StateError(
          'The Music copy does not belong to the selected Catalog Item');
    }
    _copy = copy;
    _album = album;
    _draft = MusicOwnedEditDraft.fromItem(copy);
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<MusicCollectionItem, MusicOwnedEditDraft>(
        schema: musicOwnedEditSchema,
        model: _copy,
        draft: _draft,
        title: musicEditHeaderTitle(
          title: _album.title,
          artist: _album.artist,
        ),
        icon: Icons.library_music_outlined,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_music_copy',
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        extraTabs: [
          EditSchemaExtraTab(
            label: 'Disc details',
            icon: Icons.album_outlined,
            content: MusicCollectionItemMediaTab(
              draft: _draft,
              mediums: _album.mediums,
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
          final payload = MusicCollectionItemUpdatePayload.partial(
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
              kindItem: widget.request.kindItem,
              scope: LibraryEntityScope.collectionItem,
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

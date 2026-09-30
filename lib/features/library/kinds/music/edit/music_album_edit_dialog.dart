import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_header_title.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_images_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_images_tabs.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_album_image_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_album_image_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_structure_tabs.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_credits_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_personal_tab.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildMusicAlbumLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _MusicAlbumEditDialog(request: request);

final class _MusicAlbumEditDialog extends ConsumerStatefulWidget {
  const _MusicAlbumEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  ConsumerState<_MusicAlbumEditDialog> createState() =>
      _MusicAlbumEditDialogState();
}

final class _MusicAlbumEditDialogState
    extends ConsumerState<_MusicAlbumEditDialog> {
  late final MusicAlbum _album;
  late final MusicAlbumEditDraft _draft;
  late final MusicAlbumCreditsEditor _creditsEditor;
  late final Future<void> _imagesLoaded;
  late Map<String, String?> _customFieldEdits;
  final Map<String, ({String listName, String value, String? mediaKind})>
      _pendingCustomFieldVocabularyValues = {};
  List<MusicAlbumImage> _albumImages = const [];
  var _albumImagesReady = false;
  var _albumImagesDirty = false;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    _album = MusicCatalogMapper.mapMetadataItemToMusic(transport);
    _draft = MusicAlbumEditDraft.fromAlbum(
      _album,
      trackingSummary: widget.request.trackingSummary,
    );
    _creditsEditor = MusicAlbumCreditsEditor(draft: _draft);
    _customFieldEdits = {
      for (final value in widget.request.customFieldValues)
        value.fieldDefinitionId: value.value,
    };
    _imagesLoaded = _loadReleaseImages();
  }

  @override
  void dispose() {
    _creditsEditor.dispose();
    super.dispose();
  }

  Future<void> _loadReleaseImages() async {
    final images = await MusicAlbumImageRepository(
      ref.read(localDatabaseProvider),
    ).listForAlbum(_album.id.value);
    if (!mounted) return;
    setState(() {
      _albumImages = images;
      _albumImagesReady = true;
    });
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<MusicAlbum, MusicAlbumEditDraft>(
        schema: musicAlbumEditSchema,
        model: _album,
        draft: _draft,
        title: musicEditHeaderTitle(
          title: _album.title,
          artist: _album.artist,
        ),
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_music_album_v2',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _album.toJson(),
          proposedFields: _draft.toAlbum().toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        extraTabs: [
          EditSchemaExtraTab(
            label: 'Classical',
            icon: Icons.queue_music_outlined,
            content: MusicAlbumCreditsTab(
              editor: _creditsEditor,
              classical: true,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'People',
            icon: Icons.people_outline,
            content: MusicAlbumCreditsTab(
              editor: _creditsEditor,
              classical: false,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'Tracks',
            icon: Icons.format_list_numbered,
            content: MusicAlbumStructureTab(
              draft: _draft,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'Personal',
            icon: Icons.headphones_outlined,
            content: MusicAlbumPersonalTab(
              draft: _draft,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'Custom Fields',
            icon: Icons.tune_outlined,
            content: CustomFieldsEditSection(
              definitions: widget.request.customFieldDefinitions,
              values: _customFieldEdits,
              accent: widget.request.accent,
              mediaKind: widget.request.type.kind.apiValue,
              onChanged: (values) => setState(() {
                _customFieldEdits = Map.of(values);
              }),
              onCustomValueChanged: (fieldDefinitionId, value) {
                final normalized = value?.trim();
                if (normalized == null || normalized.isEmpty) {
                  _pendingCustomFieldVocabularyValues.remove(fieldDefinitionId);
                  return;
                }
                final definition = widget.request.customFieldDefinitions
                    .where((item) => item.id == fieldDefinitionId)
                    .firstOrNull;
                _pendingCustomFieldVocabularyValues[fieldDefinitionId] = (
                  listName: 'customField:$fieldDefinitionId',
                  value: normalized,
                  mediaKind: definition?.mediaKind ??
                      widget.request.type.kind.apiValue,
                );
              },
            ),
          ),
          EditSchemaExtraTab(
            label: 'Covers',
            icon: Icons.photo_camera_outlined,
            content: _albumImagesReady
                ? MusicAlbumCoversTab(
                    albumId: _album.id.value,
                    draft: _draft,
                    images: _albumImages,
                    onImagesChanged: (images) => setState(() {
                      _albumImages = images;
                      _albumImagesDirty = true;
                    }),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          EditSchemaExtraTab(
            label: 'My Images',
            icon: Icons.collections_outlined,
            content: _albumImagesReady
                ? MusicAlbumMyImagesTab(
                    albumId: _album.id.value,
                    images: _albumImages,
                    accent: widget.request.accent,
                    onImagesChanged: (images) => setState(() {
                      _albumImages = images;
                      _albumImagesDirty = true;
                    }),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          EditSchemaExtraTab(
            label: 'Links',
            icon: Icons.public,
            content: MusicAlbumLinksTab(
              draft: _draft,
              accent: widget.request.accent,
            ),
          ),
        ],
        onSave: (_) async {
          await _imagesLoaded;
          final updatedAlbum = _draft.toAlbum();
          if (_draft.hasOwnedMediumIndexChanges) {
            await MusicOwnedRepository(ref.read(localDatabaseProvider))
                .remapMediumDetails(
              catalogRef: widget.request.kindItem.reference,
              oldToNewIndex: _draft.ownedMediumIndexRemap,
              removedIndexes: _draft.removedOwnedMediumIndexes,
            );
          }
          if (_albumImagesDirty) {
            await MusicAlbumImageRepository(ref.read(localDatabaseProvider))
                .replaceForAlbum(_album.id.value, _albumImages);
            ref.invalidate(musicAlbumImagesProvider(_album.id.value));
          }
          if (!mounted || !context.mounted) return;
          await _persistPendingCustomFieldVocabularyValues();
          if (!mounted || !context.mounted) return;
          final candidate =
              widget.request.kindItem.kindCapability.withKindMetadata(
            updatedAlbum,
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              kindItem: candidate,
              scope: LibraryEntityScope.work,
              customFieldEdits: Map.unmodifiable(_customFieldEdits),
              tracking: _draft.trackingSelection(
                widget.request.kindItem.reference.rootScope,
              ),
            ),
          );
        },
      );

  Future<void> _persistPendingCustomFieldVocabularyValues() async {
    if (_pendingCustomFieldVocabularyValues.isEmpty) return;
    final repository = PickListRepository(ref.read(localDatabaseProvider));
    for (final pending in _pendingCustomFieldVocabularyValues.values) {
      await repository.addValue(
        pending.listName,
        pending.value,
        mediaKind: pending.mediaKind,
      );
    }
    _pendingCustomFieldVocabularyValues.clear();
  }
}

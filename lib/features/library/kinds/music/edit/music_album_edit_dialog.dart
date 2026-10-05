import 'package:collectarr_app/features/library/kinds/music/forms/music_personal_form_layout.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_header_title.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_images_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_images_tabs.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_album_image_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_structure_tabs.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_credits_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_grade_field.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_vocabulary_edit_change.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/library/edit/sections/library_entry_personal_section.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_signed_by_personal_field.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_listening_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
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
  Set<String> _originalImageIds = {};
  MusicListeningEditDraft? _listening;
  var _albumImagesReady = false;
  var _albumImagesDirty = false;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    _album = MusicCatalogMapper.mapMetadataItemToMusic(transport);
    _draft = MusicAlbumEditDraft.fromAlbum(_album);
    _creditsEditor = MusicAlbumCreditsEditor(draft: _draft);
    _customFieldEdits = {
      for (final value in widget.request.customFieldValues)
        value.fieldDefinitionId: value.value,
    };
    _imagesLoaded = _loadReleaseImages();
  }

  @override
  void dispose() {
    _listening?.dispose();
    super.dispose();
  }

  Future<void> _loadReleaseImages() async {
    final images = await MusicAlbumImageRepository(
      ref.read(localDatabaseProvider),
    ).listForAlbum(_libraryItemId);
    final listeningRef = widget.request.libraryEntry?.ref;
    final events = listeningRef == null
        ? const <MusicListenEvent>[]
        : await MusicListeningRepository(ref.read(localDatabaseProvider))
            .listForLibraryEntry(listeningRef);
    if (!mounted) return;
    setState(() {
      _originalImageIds = images.map((image) => image.id).toSet();
      _listening = listeningRef == null
          ? null
          : MusicListeningEditDraft(listeningRef, events);
      _albumImages = images;
      _albumImagesReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final personal = LibraryEntryEditScope.maybeOf(context);
    return LibraryEditSchemaDialog<MusicAlbum, MusicAlbumEditDraft>(
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
        coreCatalogRef: coreCatalogRefForEditRequest(widget.request),
        originalFields: _album.toJson(),
        proposedFields: _draft.toAlbum().toJson(),
      ),
      onCancel: () => Navigator.of(context).pop(),
      onPrevious: widget.request.onPrevious,
      onNext: widget.request.onNext,
      extraTabs: [
        EditSchemaExtraTab(
          id: 'classical',
          label: 'Classical',
          icon: Icons.queue_music_outlined,
          validate: () => _creditsEditor.hasIncompleteContributions(
            classical: true,
          )
              ? 'Complete or remove each unfinished music credit'
              : null,
          content: MusicAlbumCreditsTab(
            editor: _creditsEditor,
            classical: true,
            accent: widget.request.accent,
          ),
        ),
        EditSchemaExtraTab(
          id: 'people',
          label: 'People',
          icon: Icons.people_outline,
          validate: () => _creditsEditor.hasIncompleteContributions(
            classical: false,
          )
              ? 'Complete or remove each unfinished music credit'
              : null,
          content: MusicAlbumCreditsTab(
            editor: _creditsEditor,
            classical: false,
            accent: widget.request.accent,
          ),
        ),
        EditSchemaExtraTab(
          id: 'tracks',
          label: 'Tracks',
          icon: Icons.format_list_numbered,
          validate: () => _draft.hasInvalidTrackDurationInput
              ? 'Track lengths must use seconds, MM:SS, or HH:MM:SS'
              : null,
          content: MusicAlbumStructureTab(
            draft: _draft,
            accent: widget.request.accent,
          ),
        ),
        EditSchemaExtraTab(
          id: 'personal',
          label: 'Personal',
          icon: Icons.headphones_outlined,
          content: _personalSection(context),
        ),
        EditSchemaExtraTab(
          id: 'custom_fields',
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
                mediaKind:
                    definition?.mediaKind ?? widget.request.type.kind.apiValue,
              );
            },
          ),
        ),
        EditSchemaExtraTab(
          id: 'covers',
          label: 'Covers',
          icon: Icons.photo_camera_outlined,
          content: _albumImagesReady
              ? MusicAlbumCoversTab(
                  albumId: _libraryItemId,
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
          id: 'my_images',
          label: 'My Images',
          icon: Icons.collections_outlined,
          content: _albumImagesReady
              ? MusicAlbumMyImagesTab(
                  albumId: _libraryItemId,
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
          id: 'links',
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
        if (!mounted || !context.mounted) return;
        final candidate = personal == null
            ? CatalogSearchCandidate.fromItem(
                MusicCatalogMapper.toCatalogItemDto(
                  updatedAlbum,
                  ref: widget.request.target?.catalogItemRef,
                ),
                basedOn: widget.request.kindItem,
              )
            : widget.request.kindItem.kindCapability
                .replacingKindData(updatedAlbum);
        await commitLibraryEdit(
          context,
          LibraryEditSelection(
            kindItem: candidate,
            customFieldEdits: Map.unmodifiable(_customFieldEdits),
            itemImageEdits: _albumImagesDirty
                ? [
                    for (final id in _originalImageIds)
                      if (!_albumImages.any((image) => image.id == id))
                        ItemImageEdit(id: id, deleted: true),
                    for (final image in _albumImages)
                      ItemImageEdit(
                        id: image.id,
                        imageData: image.imageData,
                        caption: image.description,
                        imageType: image.purpose == MusicAlbumImagePurpose.cover
                            ? image.imageType
                            : 'personal:${image.imageType}',
                        sortOrder: image.sortOrder,
                        createdAt: image.createdAt,
                      ),
                  ]
                : const [],
            localChanges: [
              if (_listening != null && personal != null) _listening!,
              LibraryVocabularyEditChange(_draft
                  .pendingDetailVocabularyValues.values
                  .expand((values) => values)),
              LibraryVocabularyEditChange(
                  _pendingCustomFieldVocabularyValues.values),
            ],
          ),
        );
      },
    );
  }

  Widget _personalSection(BuildContext context) {
    final personal = LibraryEntryEditScope.maybeOf(context);
    if (personal == null) {
      return const Text('Personal fields belong to your local library entry.');
    }
    personal.used = true;
    return LibraryEntryPersonalSection(
      draft: personal,
      layoutBuilder: musicPersonalFormLayout,
      additionalFields: {
        'grade': MusicGradeField(
          value: personal.text('grade'),
          onChanged: (value) {
            personal.set('grade', value ?? '');
            final normalized = value?.trim();
            final vocabularyChangeKey =
                'vocabulary:${MusicVocabularies.grade.key}';
            if (normalized == null ||
                normalized.isEmpty ||
                normalized == 'Ungraded') {
              personal.pendingChanges.remove(vocabularyChangeKey);
            } else {
              personal.pendingChanges[vocabularyChangeKey] =
                  LibraryVocabularyEditChange([
                (
                  listName: MusicVocabularies.grade.key,
                  value: normalized,
                  mediaKind: 'music',
                ),
              ]);
            }
          },
        ),
        'signed_by': MusicSignedByPersonalField(
          value: personal.text('signed_by'),
          onChanged: (value) {
            personal.set('signed_by', value ?? '');
            personal.pendingChanges['vocabulary:music.signed_by'] =
                LibraryVocabularyEditChange([
              for (final signer in splitPickListValues(value ?? ''))
                (
                  listName: 'music.signed_by',
                  value: signer,
                  mediaKind: 'music',
                ),
            ]);
          },
        ),
      },
      history: _listening == null
          ? const LinearProgressIndicator()
          : MusicListeningDraftSection(draft: _listening!),
    );
  }

  String get _libraryItemId =>
      widget.request.target?.id ??
      widget.request.kindItem.catalogRef?.id ??
      (throw StateError('Music editing requires an explicit target.'));
}

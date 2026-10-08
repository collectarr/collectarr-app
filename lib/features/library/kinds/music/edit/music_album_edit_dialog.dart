import 'package:collectarr_app/features/library/kinds/music/forms/music_personal_form_layout.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_header_title.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_images_tabs.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_album_image_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_structure_tabs.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_credits_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_grade_field.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_signed_by_personal_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
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
    final images = await loadMusicAlbumImages(
      ref.read(localDatabaseProvider),
      _libraryItemId,
    );
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
    final vocabularyEdits = personal?.vocabularyEdits ?? _draft.vocabularyEdits;
    _draft.vocabularyEdits = vocabularyEdits;
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
      vocabularyAccumulator: vocabularyEdits,
      accent: widget.request.accent,
      tabOrderKey: 'library_edit_tabs_music_album_v2',
      contributions: LibraryEditSchemaContributions(
        personal: LibraryEditPersonalTabContribution(
          svgAsset: 'assets/tab_icons/user.svg',
          afterTabId: 'tracks',
          layoutBuilder: musicPersonalFormLayout,
          additionalFieldsBuilder: (personal) => {
            'grade': MusicGradeField(
              value: personal.text('grade'),
              onChanged: (value) {
                personal.set('grade', value ?? '');
                final normalized = value?.trim();
                personal.vocabularyEdits.replaceValue(
                  fieldId: 'personal:music:grade',
                  listName: MusicVocabularies.grade.key,
                  value: normalized == 'Ungraded' ? null : normalized,
                  mediaKind: 'music',
                );
              },
            ),
            'signed_by': MusicSignedByPersonalField(
              value: personal.text('signed_by'),
              onChanged: (value) {
                personal.set('signed_by', value ?? '');
                personal.vocabularyEdits.replaceValues(
                  fieldId: 'personal:music:signed_by',
                  listName: 'music.signed_by',
                  values: splitPickListValues(value ?? ''),
                  mediaKind: 'music',
                );
              },
            ),
          },
          historyBuilder: (_) => _listening == null
              ? const LinearProgressIndicator()
              : MusicListeningDraftSection(draft: _listening!),
        ),
        customFields: LibraryEditCustomFieldsTabContribution(
          svgAsset: 'assets/tab_icons/pen-to-square.svg',
          definitions: widget.request.customFieldDefinitions,
          values: _customFieldEdits,
          onChanged: (values) => setState(() {
            _customFieldEdits = Map.of(values);
          }),
          onCustomValueChanged: (fieldDefinitionId, value) {
            final definition = widget.request.customFieldDefinitions
                .where((item) => item.id == fieldDefinitionId)
                .firstOrNull;
            _draft.vocabularyEdits.replaceValue(
              fieldId: 'custom:$fieldDefinitionId',
              listName: 'customField:$fieldDefinitionId',
              value: value,
              mediaKind:
                  definition?.mediaKind ?? widget.request.type.kind.apiValue,
            );
          },
        ),
        images: _albumImagesReady
            ? LibraryEditImagesTabContribution(
                svgAsset: 'assets/tab_icons/image.svg',
                afterTabId: 'covers',
                images: [
                  for (final image in _albumImages)
                    if (image.purpose == MusicAlbumImagePurpose.personal) image,
                ],
                title: 'My Images',
                emptyMessage:
                    'Add your own images (max. 5). Add a description and an image type for each.',
                maximumImages: 5,
                defaultImageType: 'other',
                uniqueImageTypes: const {},
                showCoverActions: false,
                imageTypeFieldBuilder: (context,
                        {required value, required onChanged}) =>
                    LibraryManagedVocabularyField(
                  label: 'Image Type',
                  listName: MusicVocabularyIds.imageType.value,
                  mediaKind: 'music',
                  value: value,
                  builtIns: MusicVocabularies.imageType.builtIns,
                  optionLabel: MusicVocabularies.imageType.optionLabel,
                  onChanged: (selected) {
                    if (selected != null) onChanged(selected);
                  },
                ),
                imageTypeLabelBuilder: MusicVocabularies.imageType.optionLabel,
                onChanged: (edits) {
                  final originalById = {
                    for (final image in _albumImages)
                      if (image.purpose == MusicAlbumImagePurpose.personal)
                        image.id: image,
                  };
                  final personalImages = <MusicAlbumImage>[];
                  for (final edit in edits) {
                    if (edit.deleted) continue;
                    final original = originalById[edit.id];
                    final imageData = edit.imageData ?? original?.imageData;
                    if (imageData == null) {
                      throw StateError(
                          'A new Music image must include its bytes.');
                    }
                    personalImages.add(
                      MusicAlbumImage(
                        id: edit.id,
                        albumId: _libraryItemId,
                        purpose: MusicAlbumImagePurpose.personal,
                        imageType: edit.imageType,
                        imageData: imageData,
                        description: edit.caption,
                        sortOrder: edit.sortOrder,
                        createdAt: edit.createdAt ??
                            original?.createdAt ??
                            DateTime.now().toUtc(),
                      ),
                    );
                  }
                  setState(() {
                    _albumImages = [
                      ..._albumImages.where(
                        (image) =>
                            image.purpose != MusicAlbumImagePurpose.personal,
                      ),
                      ...personalImages,
                    ];
                    _albumImagesDirty = true;
                  });
                },
              )
            : null,
        links: LibraryEditLinksTabContribution(
          svgAsset: 'assets/tab_icons/globe.svg',
          afterTabId: 'my_images',
          links: [
            for (final link in _draft.externalLinks)
              LibraryExternalLinkValue(
                url: link.url,
                title: link.title ?? '',
                description: link.description ?? '',
              ),
          ],
          onChanged: (links) {
            _draft.externalLinks = [
              for (final link in links)
                MusicExternalLink(
                  url: link.url.trim(),
                  title: _nullable(link.title),
                  description: _nullable(link.description),
                ),
            ];
          },
        ),
      ),
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
          svgAsset: 'assets/tab_icons/violin.svg',
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
          svgAsset: 'assets/tab_icons/users.svg',
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
          svgAsset: 'assets/tab_icons/list-ol.svg',
          validate: () => _draft.trackList.hasInvalidTrackDurationInput
              ? 'Track lengths must use seconds, MM:SS, or HH:MM:SS'
              : null,
          content: MusicAlbumStructureTab(
            draft: _draft,
            accent: widget.request.accent,
          ),
        ),
        EditSchemaExtraTab(
          id: 'covers',
          label: 'Covers',
          svgAsset: 'assets/tab_icons/camera.svg',
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
        if (!_albumImagesReady)
          const EditSchemaExtraTab(
            id: 'my_images',
            label: 'My Images',
            svgAsset: 'assets/tab_icons/image.svg',
            content: Center(child: CircularProgressIndicator()),
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
                        imageType: image.storageImageType,
                        sortOrder: image.sortOrder,
                        createdAt: image.createdAt,
                      ),
                  ]
                : const [],
            localChanges: [
              if (_listening != null && personal != null) _listening!,
              if (personal == null && !vocabularyEdits.isEmpty)
                vocabularyEdits.toEditChange(
                  defaultMediaKind: widget.request.type.kind.apiValue,
                ),
            ],
          ),
        );
      },
    );
  }

  String get _libraryItemId =>
      widget.request.target?.id ??
      widget.request.kindItem.catalogRef?.id ??
      (throw StateError('Music editing requires an explicit target.'));
}

String? _nullable(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

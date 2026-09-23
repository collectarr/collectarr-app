import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_entity_ownership.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_images_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_images_tabs.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_image.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_release_image_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_release_image_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_copies_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_listening_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_structure_tabs.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_credits_tab.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildMusicReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _MusicReleaseEditDialog(request: request);

final class _MusicReleaseEditDialog extends ConsumerStatefulWidget {
  const _MusicReleaseEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  ConsumerState<_MusicReleaseEditDialog> createState() =>
      _MusicReleaseEditDialogState();
}

final class _MusicReleaseEditDialogState
    extends ConsumerState<_MusicReleaseEditDialog> {
  late final MusicReleaseGroup _group;
  late final MusicRelease _release;
  late final MusicReleaseEditDraft _draft;
  late final Future<void> _imagesLoaded;
  late Map<String, String?> _customFieldEdits;
  List<MusicReleaseImage> _releaseImages = const [];
  var _releaseImagesReady = false;
  var _releaseImagesDirty = false;

  @override
  void initState() {
    super.initState();
    final transport =
        widget.request.kindItem.mapTransport((transport) => transport);
    final canonical = transport.kindMetadata;
    _group = canonical is MusicReleaseGroup
        ? canonical
        : MusicReleaseGroup.fromJson(transport.payload);
    final requestedReleaseId = switch (widget.request.node) {
      LibraryReleaseRef(:final releaseId) => releaseId,
      LibraryCopyRef(:final releaseId) => releaseId,
      _ => null,
    };
    _release = resolveMusicReleaseForEdit(
      _group,
      requestedReleaseId: requestedReleaseId,
      editPrimaryRelease: widget.request.editPrimaryRelease,
    );
    _draft = MusicReleaseEditDraft.fromRelease(
      _release,
      trackingSummary: widget.request.trackingSummary,
    );
    _customFieldEdits = {
      for (final value in widget.request.customFieldValues)
        value.fieldDefinitionId: value.value,
    };
    _imagesLoaded = _loadReleaseImages();
  }

  Future<void> _loadReleaseImages() async {
    final images = await MusicReleaseImageRepository(
      ref.read(localDatabaseProvider),
    ).listForRelease(_release.id.value);
    if (!mounted) return;
    setState(() {
      _releaseImages = images;
      _releaseImagesReady = true;
    });
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<MusicRelease, MusicReleaseEditDraft>(
        schema: musicReleaseEditSchema,
        model: _release,
        draft: _draft,
        title: musicReleaseEditSchema.title?.call(_release) ?? 'Edit release',
        icon: widget.request.type.identity.icon,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_music_release',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _release.toJson(),
          proposedFields: _draft.toRelease().toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        extraTabs: [
          EditSchemaExtraTab(
            label: 'Media',
            icon: Icons.album_outlined,
            content: MusicReleaseStructureTab(
              draft: _draft,
              section: MusicReleaseStructureSection.media,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'Tracks',
            icon: Icons.format_list_numbered,
            content: MusicReleaseStructureTab(
              draft: _draft,
              section: MusicReleaseStructureSection.tracks,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'Credits',
            icon: Icons.people_alt_outlined,
            content: MusicReleaseCreditsTab(
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
              onChanged: (values) => setState(() {
                _customFieldEdits = Map.of(values);
              }),
            ),
          ),
          EditSchemaExtraTab(
            label: 'Covers',
            icon: Icons.image_outlined,
            content: _releaseImagesReady
                ? MusicReleaseCoversTab(
                    releaseId: _release.id.value,
                    draft: _draft,
                    images: _releaseImages,
                    accent: widget.request.accent,
                    onImagesChanged: (images) => setState(() {
                      _releaseImages = images;
                      _releaseImagesDirty = true;
                    }),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          EditSchemaExtraTab(
            label: 'My Images',
            icon: Icons.collections_outlined,
            content: _releaseImagesReady
                ? MusicReleaseMyImagesTab(
                    releaseId: _release.id.value,
                    images: _releaseImages,
                    accent: widget.request.accent,
                    onImagesChanged: (images) => setState(() {
                      _releaseImages = images;
                      _releaseImagesDirty = true;
                    }),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          EditSchemaExtraTab(
            label: 'Links',
            icon: Icons.link_outlined,
            content: MusicReleaseLinksTab(
              draft: _draft,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'Listening',
            icon: Icons.headphones_outlined,
            content: MusicReleaseListeningTab(
              item: widget.request.kindItem,
              group: _group,
              release: _release,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'Owned Copies',
            icon: Icons.library_music_outlined,
            content: buildMusicOwnedCopiesTab(
              item: widget.request.kindItem,
              release: _release,
              accent: widget.request.accent,
              type: widget.request.type,
            ),
          ),
        ],
        onSave: (_) async {
          await _imagesLoaded;
          final updatedRelease = _draft.toRelease();
          if (_draft.hasOwnedMediumIndexChanges) {
            final releaseRef = musicReleaseRefForRoot(
              widget.request.kindItem.catalogRef,
              _release.id.value,
            );
            await MusicOwnedRepository(ref.read(localDatabaseProvider))
                .remapMediumDetails(
              releaseRef: releaseRef,
              oldToNewIndex: _draft.ownedMediumIndexRemap,
              removedIndexes: _draft.removedOwnedMediumIndexes,
            );
          }
          if (_releaseImagesDirty) {
            await MusicReleaseImageRepository(ref.read(localDatabaseProvider))
                .replaceForRelease(_release.id.value, _releaseImages);
            ref.invalidate(musicReleaseImagesProvider(_release.id.value));
          }
          if (!mounted || !context.mounted) return;
          final updatedGroup = _replaceRelease(_group, updatedRelease);
          final candidate =
              widget.request.kindItem.withKindMetadata(updatedGroup);
          final releaseRef = musicReleaseRefForRoot(
            widget.request.kindItem.catalogRef,
            _release.id.value,
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              kindItem: candidate,
              scope: LibraryEntityScope.release,
              customFieldEdits: Map.unmodifiable(_customFieldEdits),
              tracking: _draft.trackingSelection(releaseRef),
            ),
          );
        },
      );
}

MusicRelease resolveMusicReleaseForEdit(
  MusicReleaseGroup group, {
  required String? requestedReleaseId,
  bool editPrimaryRelease = false,
}) {
  if (requestedReleaseId != null) {
    for (final release in group.releases) {
      if (release.id.value == requestedReleaseId) return release;
    }
    throw StateError(
      'Music release "$requestedReleaseId" is not present in the canonical release group graph',
    );
  }
  if (!editPrimaryRelease) {
    throw StateError(
      'Music release edit requires an explicit release selection or primary-release intent',
    );
  }
  final primary = group.primaryRelease;
  if (primary != null) return primary;
  throw StateError('Music release edit requires a concrete release');
}

MusicReleaseGroup _replaceRelease(
  MusicReleaseGroup group,
  MusicRelease updatedRelease,
) {
  return MusicReleaseGroup(
    id: group.id,
    title: group.title,
    sortTitle: group.sortTitle,
    artist: group.artist,
    originalTitle: group.originalTitle,
    synopsis: group.synopsis,
    originalReleaseDate: group.originalReleaseDate,
    recordingDate: group.recordingDate,
    studio: group.studio,
    isLive: group.isLive,
    genres: group.genres,
    coverImageUrl: group.coverImageUrl,
    coverImageKey: group.coverImageKey,
    localCoverImagePath: group.localCoverImagePath,
    localBackImagePath: group.localBackImagePath,
    localThumbnailImagePath: group.localThumbnailImagePath,
    releases: [
      for (final release in group.releases)
        release.id == updatedRelease.id ? updatedRelease : release,
    ],
    externalLinks: group.externalLinks,
    createdAt: group.createdAt,
    updatedAt: group.updatedAt,
  );
}

import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_entity_ownership.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_images_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_owned_copies_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_listening_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_structure_tabs.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';

Widget buildMusicReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _MusicReleaseEditDialog(request: request);

final class _MusicReleaseEditDialog extends StatefulWidget {
  const _MusicReleaseEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_MusicReleaseEditDialog> createState() =>
      _MusicReleaseEditDialogState();
}

final class _MusicReleaseEditDialogState
    extends State<_MusicReleaseEditDialog> {
  late final MusicReleaseGroup _group;
  late final MusicRelease _release;
  late final MusicReleaseEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final canonical = transport.kindMetadata;
    _group = canonical is MusicReleaseGroup
        ? canonical
        : MusicReleaseGroup.fromJson(transport.payload);
    final requestedReleaseId = switch (widget.request.node) {
      LibraryReleaseNodeRef(:final releaseId) => releaseId,
      _ => null,
    };
    _release = _findRelease(_group, requestedReleaseId);
    _draft = MusicReleaseEditDraft.fromRelease(
      _release,
      trackingSummary: widget.request.trackingSummary,
    );
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
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        extraTabs: [
          EditSchemaExtraTab(
            label: 'Media',
            icon: Icons.album_outlined,
            content: MusicReleaseStructureTab(
              release: _release,
              section: MusicReleaseStructureSection.media,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'Tracks',
            icon: Icons.queue_music_outlined,
            content: MusicReleaseStructureTab(
              release: _release,
              section: MusicReleaseStructureSection.tracks,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'Credits',
            icon: Icons.people_outline,
            content: MusicReleaseStructureTab(
              release: _release,
              section: MusicReleaseStructureSection.credits,
              accent: widget.request.accent,
            ),
          ),
          EditSchemaExtraTab(
            label: 'Images & Links',
            icon: Icons.image_outlined,
            content: MusicReleaseImagesLinksTab(
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
            ),
          ),
        ],
        onSave: (_) {
          final updatedRelease = _draft.toRelease();
          final updatedGroup = _replaceRelease(_group, updatedRelease);
          final candidate =
              widget.request.kindItem.withKindMetadata(updatedGroup);
          final releaseRef = musicReleaseRefForRoot(
            widget.request.kindItem.catalogRef,
            _release.id.value,
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              item: candidate.editMetadata,
              kindItem: candidate,
              personal: null,
              scope: LibraryEditScope.release,
              tracking: _draft.trackingSelection(releaseRef),
            ),
          );
        },
      );
}

MusicRelease _findRelease(MusicReleaseGroup group, String? releaseId) {
  if (releaseId != null) {
    for (final release in group.releases) {
      if (release.id.value == releaseId) return release;
    }
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

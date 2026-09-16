import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_images_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_images_links_tab.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';

/// Dispatches Music editing to the entity that the caller selected.
///
/// `all` is only used by catalog/provider correction flows. It is a small
/// composition of two typed schema renderers, rather than a shared draft that
/// mixes Group, Release, Copy and Tracking state.
Widget buildMusicLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  if (request.node case LibraryReleaseNodeRef()) {
    return buildMusicReleaseLibraryEditDialog(context, request);
  }
  if (request.node case LibraryTitleNodeRef()) {
    return buildMusicReleaseGroupLibraryEditDialog(context, request);
  }
  return switch (request.resolvedScope) {
    LibraryEditScope.media =>
      buildMusicReleaseGroupLibraryEditDialog(context, request),
    LibraryEditScope.release => buildMusicReleaseLibraryEditDialog(
        context,
        request,
      ),
    LibraryEditScope.all => MusicCatalogEditDialog(request: request),
  };
}

/// A typed two-entity editor used when a catalog item is being corrected
/// before it has entered the library and therefore has no structural node.
final class MusicCatalogEditDialog extends StatefulWidget {
  const MusicCatalogEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<MusicCatalogEditDialog> createState() => _MusicCatalogEditDialogState();
}

final class _MusicCatalogEditDialogState extends State<MusicCatalogEditDialog>
    with SingleTickerProviderStateMixin {
  late final MusicReleaseGroup _group;
  late final MusicRelease _release;
  late final MusicReleaseGroupEditDraft _groupDraft;
  late final MusicReleaseEditDraft _releaseDraft;
  late final TabController _tabs;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _group = widget.request.kindItem.mapTransport(
      MusicCatalogMapper.mapMetadataItemToMusic,
    );
    _release = _group.primaryRelease ??
        MusicRelease(
          id: MusicReleaseId('${_group.id.value}:release'),
          releaseGroupId: _group.id,
          title: _group.title,
        );
    _groupDraft = MusicReleaseGroupEditDraft.fromReleaseGroup(_group);
    _releaseDraft = MusicReleaseEditDraft.fromRelease(
      _release,
      trackingSummary: widget.request.trackingSummary,
    );
    _tabs = TabController(length: 4, initialIndex: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: widget.request.accent,
      icon: widget.request.type.identity.icon,
      title: 'Edit ${_group.title}',
      badges: const <Widget>[],
      tabController: _tabs,
      tabs: const [
        EditTab(icon: Icons.library_music_outlined, label: 'Release Group'),
        EditTab(icon: Icons.album_outlined, label: 'Release'),
        EditTab(icon: Icons.language_outlined, label: 'Links'),
        EditTab(icon: Icons.image_outlined, label: 'Release Images & Links'),
      ],
      views: [
        _schemaView<MusicReleaseGroup, MusicReleaseGroupEditDraft>(
          schema: musicReleaseGroupEditSchema,
          model: _group,
          draft: _groupDraft,
          tabOrderKey: 'library_edit_tabs_music_catalog_group',
        ),
        _schemaView<MusicRelease, MusicReleaseEditDraft>(
          schema: musicReleaseEditSchema,
          model: _release,
          draft: _releaseDraft,
          tabOrderKey: 'library_edit_tabs_music_catalog_release',
        ),
        MusicReleaseGroupImagesLinksTab(
          draft: _groupDraft,
          accent: widget.request.accent,
        ),
        MusicReleaseImagesLinksTab(
          draft: _releaseDraft,
          accent: widget.request.accent,
        ),
      ],
      onClose: () => Navigator.of(context).pop(),
      onCancel: () => Navigator.of(context).pop(),
      onSave: _submit,
      onPrevious: widget.request.onPrevious,
      onNext: widget.request.onNext,
      allowTabReorder: false,
      tabOrderKey: 'library_edit_tabs_music_catalog',
    );
  }

  Widget _schemaView<TModel, TDraft>({
    required EditSchema<TModel, TDraft> schema,
    required TModel model,
    required TDraft draft,
    required String tabOrderKey,
  }) {
    return EditSchemaRenderer<TModel, TDraft>(
      schema: schema,
      model: model,
      draft: draft,
      showTitle: false,
      showTabBar: true,
      showFooter: false,
      tabAccent: widget.request.accent,
      tabOrderKey: tabOrderKey,
      onCancel: () => Navigator.of(context).pop(),
      onSave: (_) {},
    );
  }

  void _submit() {
    final groupError = musicReleaseGroupEditSchema.validate?.call(
      _group,
      _groupDraft,
    );
    final releaseError = musicReleaseEditSchema.validate?.call(
      _release,
      _releaseDraft,
    );
    final error = groupError ?? releaseError;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final updatedGroup = _replaceRelease(
      _groupDraft.toReleaseGroup(),
      _releaseDraft.toRelease(),
    );
    final candidate = widget.request.kindItem.withKindMetadata(updatedGroup);
    Navigator.of(context).pop(
      LibraryEditSelection(
        item: candidate.editMetadata,
        kindItem: candidate,
        personal: null,
        scope: LibraryEditScope.media,
      ),
    );
  }
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
      if (group.releases.isEmpty) updatedRelease,
      for (final release in group.releases)
        release.id == updatedRelease.id ? updatedRelease : release,
    ],
    externalLinks: group.externalLinks,
    createdAt: group.createdAt,
    updatedAt: group.updatedAt,
  );
}

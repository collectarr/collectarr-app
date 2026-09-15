import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_schema.dart';
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
    _tabs = TabController(length: 3, initialIndex: 1, vsync: this);
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
        _MusicGroupLinksEditor(
          draft: _groupDraft,
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

final class _MusicGroupLinksEditor extends StatefulWidget {
  const _MusicGroupLinksEditor({required this.draft, required this.accent});

  final MusicReleaseGroupEditDraft draft;
  final Color accent;

  @override
  State<_MusicGroupLinksEditor> createState() => _MusicGroupLinksEditorState();
}

final class _MusicGroupLinksEditorState extends State<_MusicGroupLinksEditor> {
  late final List<_MusicLinkRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final link in widget.draft.externalLinks)
        _MusicLinkRow.fromLink(link),
    ];
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _syncDraft() {
    widget.draft.externalLinks = [
      for (final row in _rows)
        if (row.url.text.trim().isNotEmpty)
          MusicExternalLink(
            url: row.url.text.trim(),
            description: row.description.text.trim().isEmpty
                ? null
                : row.description.text.trim(),
            source: 'manual',
          ),
    ];
  }

  void _add() {
    setState(() => _rows.add(_MusicLinkRow.empty()));
  }

  void _remove(int index) {
    final row = _rows.removeAt(index);
    row.dispose();
    _syncDraft();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        EditSection(
          title: 'External links',
          accent: widget.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_rows.isEmpty)
                const Text(
                  'Add web links for stores, discography pages or other references.',
                ),
              for (var index = 0; index < _rows.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('musicExternalLinkUrlField_$index'),
                        controller: _rows[index].url,
                        decoration: const InputDecoration(labelText: 'URL'),
                        onChanged: (_) => _syncDraft(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        key: ValueKey(
                          'musicExternalLinkDescriptionField_$index',
                        ),
                        controller: _rows[index].description,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        onChanged: (_) => _syncDraft(),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () => _remove(index),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: const Text('Add link'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _MusicLinkRow {
  _MusicLinkRow({required this.url, required this.description});

  factory _MusicLinkRow.empty() => _MusicLinkRow(
        url: TextEditingController(),
        description: TextEditingController(),
      );

  factory _MusicLinkRow.fromLink(MusicExternalLink link) => _MusicLinkRow(
        url: TextEditingController(text: link.url),
        description: TextEditingController(
          text: link.description ?? link.title ?? '',
        ),
      );

  final TextEditingController url;
  final TextEditingController description;

  void dispose() {
    url.dispose();
    description.dispose();
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
    releases: [
      if (group.releases.isEmpty) updatedRelease,
      for (final release in group.releases)
        release.id == updatedRelease.id ? updatedRelease : release,
    ],
    externalLinks: group.externalLinks,
    metadataJson: group.metadataJson,
    createdAt: group.createdAt,
    updatedAt: group.updatedAt,
  );
}

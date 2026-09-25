import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_images_links_tab.dart';
import 'package:flutter/material.dart';

Widget buildMusicReleaseGroupLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _MusicReleaseGroupEditDialog(request: request);

final class _MusicReleaseGroupEditDialog extends StatefulWidget {
  const _MusicReleaseGroupEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_MusicReleaseGroupEditDialog> createState() =>
      _MusicReleaseGroupEditDialogState();
}

final class _MusicReleaseGroupEditDialogState
    extends State<_MusicReleaseGroupEditDialog> {
  late final MusicReleaseGroup _group;
  late final MusicReleaseGroupEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    final canonical = transport.kindMetadata;
    _group = canonical is MusicReleaseGroup
        ? canonical
        : MusicReleaseGroup.fromJson(transport.payload);
    _draft = MusicReleaseGroupEditDraft.fromReleaseGroup(_group);
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<MusicReleaseGroup, MusicReleaseGroupEditDraft>(
        schema: musicReleaseGroupEditSchema,
        model: _group,
        draft: _draft,
        title: musicReleaseGroupEditSchema.title?.call(_group) ?? 'Edit music',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_music_release_group',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _group.toJson(),
          proposedFields: _draft.toReleaseGroup().toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        extraTabs: [
          EditSchemaExtraTab(
            label: 'Covers',
            icon: Icons.photo_library_outlined,
            content: MusicReleaseGroupImagesLinksTab(
              draft: _draft,
              accent: widget.request.accent,
              section: MusicReleaseGroupAssetSection.covers,
            ),
          ),
          EditSchemaExtraTab(
            label: 'Links',
            icon: Icons.public,
            content: MusicReleaseGroupImagesLinksTab(
              draft: _draft,
              accent: widget.request.accent,
              section: MusicReleaseGroupAssetSection.links,
            ),
          ),
        ],
        onSave: (_) {
          final updated = _draft.toReleaseGroup();
          final candidate = widget.request.kindItem.kindCapability.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.withKindMetadata(updated),
            ),
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              kindItem: candidate,
            ),
          );
        },
      );
}

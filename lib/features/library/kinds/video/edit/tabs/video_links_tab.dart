import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/tabs/video_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/video_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/video/detail/video_external_links_section.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoEditLinksTab extends ConsumerWidget {
  const VideoEditLinksTab({
    super.key,
    required this.item,
    required this.accent,
    required this.videoEdit,
  });

  final LibraryMetadataItem item;
  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerLinks = item.trailerUrls;
    return EditTabShell(
      children: [
        if (providerLinks.isNotEmpty)
          EditSection(
            title: 'Provider links',
            accent: accent,
            child: VideoExternalLinksSection(
              title: 'Provider links',
              links: providerLinks,
              accent: accent,
            ),
          ),
        EditSection(
          title: 'User links',
          accent: accent,
          child: LibraryExternalLinksEditor(
            title: 'User links',
            items: videoEdit.userLinkEdits,
            onAdd: () => videoEdit.userLinkEdits.add(
              EditableUserExternalLink.fromTrailerLink(
                TrailerLink(
                  url: '',
                  source: 'manual',
                  isAutomatic: false,
                  kind: 'external',
                ),
                kind: 'custom',
              ),
            ),
          ),
        ),
        EditSection(
          title: 'Trailers',
          accent: accent,
          child: LibraryExternalLinksEditor(
            title: 'Trailers',
            items: videoEdit.userTrailerEdits,
            onAdd: () => videoEdit.userTrailerEdits.add(
              EditableUserExternalLink.fromTrailerLink(
                TrailerLink(
                  url: '',
                  source: 'manual',
                  isAutomatic: false,
                  kind: 'trailer',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

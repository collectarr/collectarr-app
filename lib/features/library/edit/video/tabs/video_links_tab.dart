import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/edit/video/video_edit_models.dart';
import 'package:collectarr_app/features/library/edit/video/video_edit_controller.dart';
import 'package:collectarr_app/features/library/detail/library_external_links_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoEditLinksTab extends ConsumerWidget {
  const VideoEditLinksTab({
    super.key,
    required this.item,
    required this.accent,
    required this.videoEdit,
  });

  final LibraryAddCatalogTransport item;
  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerLinks = item.toTransportItem().trailerUrls;
    return EditTabShell(
      children: [
        if (providerLinks.isNotEmpty)
          EditSection(
            title: 'Provider links',
            accent: accent,
            child: LibraryExternalLinksSection(
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
                TrailerLinkDto(
                  url: '',
                  source: 'manual',
                  isAutomatic: false,
                  kind: 'external',
                ),
                catalogRef: item.catalogRef,
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
                TrailerLinkDto(
                  url: '',
                  source: 'manual',
                  isAutomatic: false,
                  kind: 'trailer',
                ),
                catalogRef: item.catalogRef,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/edit/covers/library_cover_editor.dart';
import 'package:collectarr_app/features/library/edit/covers/library_cover_images_tab.dart';
import 'package:collectarr_app/features/library/edit/covers/library_online_cover_picker_dialog.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ComicCoversTab extends ConsumerWidget {
  const ComicCoversTab(
      {super.key,
      required this.images,
      required this.coverImageUrl,
      required this.originalCoverImageUrl,
      required this.onCoverImageUrlChanged,
      required this.onEdits,
      required this.searchTitle});
  final List<ItemImageContent> images;
  final String coverImageUrl;
  final String originalCoverImageUrl;
  final ValueChanged<String> onCoverImageUrlChanged;
  final ValueChanged<List<ItemImageEdit>> onEdits;

  /// The comic's current title, offered as the first Find Online search term.
  final String Function() searchTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LibraryCoverImagesTab(
      images: images,
      coverImageUrl: coverImageUrl,
      originalCoverImageUrl: originalCoverImageUrl,
      onCoverImageUrlChanged: onCoverImageUrlChanged,
      onEdits: onEdits,
      frontLabel: 'Front Cover',
      backLabel: 'Back Cover',
      placeholderIcon: AppIcons.bookOpen,
      findOnline: (context) async {
        final api = ref.read(apiClientProvider);
        final candidate = await showAppDialog<LibraryOnlineCoverCandidate>(
          context: context,
          builder: (_) => LibraryOnlineCoverPickerDialog(
            hint: 'Comic title',
            tokens: [searchTitle()],
            search: (query, terms) async => [
              for (final item in await searchLibraryMetadataCandidates(
                  api, CatalogMediaKind.comic, query: query, limit: 36))
                if (item.summary.imageUrl?.trim().isNotEmpty == true)
                  LibraryOnlineCoverCandidate(
                      title: item.summary.primaryLabel,
                      subtitle: item.summary.subtitle ?? '',
                      imageUrl: item.summary.imageUrl!),
            ],
          ),
        );
        return candidate == null
            ? null
            : LibraryOnlineCover(
                url: candidate.imageUrl, description: candidate.title);
      });
}

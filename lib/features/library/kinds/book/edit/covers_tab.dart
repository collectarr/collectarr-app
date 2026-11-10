import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/edit/covers/editor.dart';
import 'package:collectarr_app/features/library/edit/covers/images_tab.dart';
import 'package:collectarr_app/features/library/edit/covers/online_cover_picker_dialog.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/metadata/query.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class BookCoversTab extends ConsumerWidget {
  const BookCoversTab(
      {super.key,
      required this.images,
      required this.coverImageUrl,
      required this.originalCoverImageUrl,
      required this.backCoverImageUrl,
      required this.originalBackCoverImageUrl,
      required this.onBackCoverImageUrlChanged,
      required this.onCoverImageUrlChanged,
      required this.onEdits,
      required this.searchTitle});
  final List<ItemImageContent> images;
  final String coverImageUrl;
  final String originalCoverImageUrl;
  final String backCoverImageUrl;
  final String originalBackCoverImageUrl;
  final ValueChanged<String> onBackCoverImageUrlChanged;
  final ValueChanged<String> onCoverImageUrlChanged;
  final ValueChanged<List<ItemImageEdit>> onEdits;

  /// The book's current title, offered as the first Find Online search term.
  final String Function() searchTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LibraryCoverImagesTab(
      images: images,
      coverImageUrl: coverImageUrl,
      originalCoverImageUrl: originalCoverImageUrl,
      backCoverImageUrl: backCoverImageUrl,
      originalBackCoverImageUrl: originalBackCoverImageUrl,
      onBackCoverImageUrlChanged: onBackCoverImageUrlChanged,
      onCoverImageUrlChanged: onCoverImageUrlChanged,
      onEdits: onEdits,
      frontLabel: 'Front Cover',
      backLabel: 'Back Cover',
      placeholderIcon: Icons.menu_book,
      findOnline: (context) async {
        final api = ref.read(apiClientProvider);
        final candidate = await showAppDialog<LibraryOnlineCoverCandidate>(
          context: context,
          builder: (_) => LibraryOnlineCoverPickerDialog(
            hint: 'Book title or ISBN',
            tokens: [searchTitle()],
            search: (query, terms) async => [
              for (final item in await searchLibraryMetadataCandidates(
                  api, CatalogMediaKind.book, query: query, limit: 36))
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

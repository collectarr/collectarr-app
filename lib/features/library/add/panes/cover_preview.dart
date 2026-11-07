import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/config/presentation/metadata_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The item in the Add dialog's confirm sheet: cover beside title, icon label
/// and year, its details and a link to eBay, as in the reference.
class LibraryAddCoverPreview extends ConsumerWidget {
  const LibraryAddCoverPreview({
    super.key,
    required this.title,
    required this.mediaKind,
    required this.imageUrl,
    required this.accent,
    required this.ebayQuery,
    this.iconLabel,
    this.year,
    this.details = const [],
  });

  final String title;
  final CatalogMediaKind mediaKind;
  final String? imageUrl;
  final Color accent;
  final String ebayQuery;
  final LibraryAddIconLabel? iconLabel;
  final int? year;
  final List<String> details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    return DefaultTextStyle.merge(
      style:
          TextStyle(fontSize: 14, height: 20 / 14, color: palette.textPrimary),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.square(
              dimension: 210,
              child: LibraryInteractiveCover(
                title: title,
                mediaKind: mediaKind,
                imageUrl: imageUrl,
                accentColor: accent,
                fallbackAspectRatio: 1,
                borderRadius: 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 24,
                          height: 26 / 24,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (iconLabel != null || year != null)
                    Row(children: [
                      if (iconLabel case final iconLabel?) ...[
                        iconLabel.icon(24, null),
                        const SizedBox(width: 5),
                        Flexible(child: Text(iconLabel.label)),
                      ],
                      if (year != null)
                        Text(iconLabel == null ? '$year' : ' ($year)',
                            style: TextStyle(
                                color: palette.isDark
                                    ? const Color(0xff888888)
                                    : palette.textMuted)),
                    ]),
                  const SizedBox(height: 13),
                  for (final detail in details) Text(detail),
                  if (ebayQuery.trim().isNotEmpty &&
                      ref.watch(uiPreferencesProvider).allowsEbayLinks(false))
                    Padding(
                      padding: const EdgeInsets.only(top: 13),
                      child: InkWell(
                        key: const ValueKey('library-add-preview-ebay'),
                        onTap: () => launchEbaySearch(ebayQuery),
                        child: Text('Find on eBay',
                            style: TextStyle(
                                color: palette.link,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: palette.link)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

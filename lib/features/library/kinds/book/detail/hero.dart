import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/config/entry_helpers.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import '../workspace/dto.dart';
import 'author_spotlight.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Book identity and edition facts shared by the inspector and details page.
class BookDetailHero extends StatelessWidget {
  const BookDetailHero({super.key, required this.request});
  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final item = request.item;
    final dto = item.dto;
    if (dto is! BookWorkspaceDto) return const SizedBox.shrink();
    final metadata = dto.metadata;
    final author = buildBookAuthorSpotlight(
        item: item, onFilterByValue: request.onFilterByValue);
    final palette = appPalette(context);
    final year = metadata.releaseDateParts?.year ?? metadata.releaseDate?.year;
    final publisher = [
      if (metadata.publisher?.isNotEmpty == true) metadata.publisher!,
      if (metadata.publicationPlace?.isNotEmpty == true)
        metadata.publicationPlace!,
      if (year != null) '($year)'
    ].join(' ');
    final dimensions = [
      metadata.widthMm,
      metadata.heightMm,
      metadata.spineThicknessMm
    ];
    final facts = [
      if (metadata.pageCount != null) '${metadata.pageCount} pages',
      if (dimensions.every((value) => value != null))
        '${dimensions.join(' x ')} mm',
      if (metadata.weightGrams != null) '${metadata.weightGrams} g',
      if (metadata.country?.isNotEmpty == true) metadata.country!,
      if (metadata.language?.isNotEmpty == true) metadata.language!,
    ];
    final personal = BookLibraryEntryProjection.fromDispatch(
            item.source.libraryEntryDispatch)
        ?.personal;
    final prices = [
      if (personal?.details.retailPriceCents != null)
        AppFormats.current
            .formatMoney(personal!.details.retailPriceCents, personal.currency),
      if (personal?.marketValueCents != null)
        'Value: ${AppFormats.current.formatMoney(personal!.marketValueCents, personal.currency)}',
    ];
    final series = [
      if (metadata.seriesTitle?.isNotEmpty == true) metadata.seriesTitle!,
      if (metadata.volumeName?.isNotEmpty == true)
        'vol. ${metadata.volumeName}',
      if (metadata.itemNumber?.isNotEmpty == true)
        'Issue #${metadata.itemNumber}',
    ].join(', ');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (author != null) ...[author, const SizedBox(height: 12)],
      if (series.isNotEmpty) Text(series),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Text(metadata.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: palette.detailHeading,
                    fontWeight: FontWeight.bold))),
        if (item.source.isEntry)
          Icon(Icons.check_box, color: palette.utilityAction),
      ]),
      if (metadata.subtitle?.isNotEmpty == true) Text(metadata.subtitle!),
      const SizedBox(height: 12),
      _BookCovers(key: ValueKey(item.target.stableKey), request: request),
      if (publisher.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(publisher, style: const TextStyle(fontWeight: FontWeight.bold))
      ],
      if (request.trackingSummary?.rating case final rating? when rating > 0)
        MediaRatingDisplay(rating: rating),
      if (metadata.editionTitle?.isNotEmpty == true)
        Text(metadata.editionTitle!),
      const SizedBox(height: 10),
      Text([
        if (dto.isbn?.isNotEmpty == true) dto.isbn!,
        if (metadata.physicalFormat?.isNotEmpty == true)
          metadata.physicalFormat!
      ].join(' | ')),
      if (facts.isNotEmpty) Text(facts.join(' | ')),
      if (prices.isNotEmpty) Text(prices.join(' | ')),
      for (final identifier in metadata.identifiers)
        if (const {'lccn', 'lcc', 'dewey'}.contains(identifier.identifierType))
          Text('${switch (identifier.identifierType) {
            'lccn' => 'LC Control No.',
            'lcc' => 'LC Classification',
            _ => 'Dewey',
          }} ${identifier.value}'),
    ]);
  }
}

class _BookCovers extends ConsumerStatefulWidget {
  const _BookCovers({super.key, required this.request});
  final LibraryInspectorRequest request;
  @override
  ConsumerState<_BookCovers> createState() => _BookCoversState();
}

class _BookCoversState extends ConsumerState<_BookCovers> {
  bool _showingBack = false;
  @override
  Widget build(BuildContext context) {
    final item = widget.request.item;
    final dto = item.dto as BookWorkspaceDto;
    final showBack = ref
        .watch(uiPreferencesProvider.select((p) => p.showInspectorBackCover));
    final hasBack = showBack &&
        (dto.metadata.backCoverImageUrl?.isNotEmpty == true ||
            item.source.personal.imageTypes.contains('back_cover'));
    final back = hasBack && _showingBack;
    return LayoutBuilder(
        builder: (context, constraints) => SizedBox(
              width: constraints.maxWidth.clamp(0, 210).toDouble(),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AspectRatio(
                    aspectRatio: 2 / 3,
                    child: LibraryCoverImage(
                      title: dto.metadata.title,
                      mediaKind: widget.request.type.kind,
                      imageUrl: back
                          ? dto.metadata.backCoverImageUrl
                          : dto.metadata.coverImageUrl ??
                              dto.metadata.thumbnailImageUrl,
                      libraryEntryRef: resolveLibraryEntrySummaryRef(
                          item, widget.request.libraryEntry),
                      localImageType: back ? 'back_cover' : 'front_cover',
                      borderRadius: 0,
                    )),
                if (hasBack)
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    for (final showBackCover in [false, true])
                      IconButton(
                        tooltip: showBackCover ? 'Back cover' : 'Front cover',
                        isSelected: back == showBackCover,
                        constraints: const BoxConstraints.tightFor(
                            width: 24, height: 24),
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.circle,
                            size: 12,
                            color: appPalette(context).textPrimary.withValues(
                                alpha: back == showBackCover ? 1 : .4)),
                        onPressed: () =>
                            setState(() => _showingBack = showBackCover),
                      ),
                  ]),
              ]),
            ));
  }
}

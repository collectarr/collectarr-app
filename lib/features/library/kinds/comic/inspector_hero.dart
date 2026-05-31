import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/item_image_picker.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kComicClzSurface = Color(0xFFFDFDFD);
const _kComicClzBorder = Color(0xFFD7DDE3);
const _kComicClzInk = Color(0xFF1E252C);
const _kComicClzMuted = Color(0xFF74808A);

Widget buildComicInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return ComicInspectorHero(request: request);
}

class ComicInspectorHero extends ConsumerWidget {
  const ComicInspectorHero({super.key, required this.request});

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = request.entry;
    final ownedItem = request.ownedItem;
    final ownedItemId = resolveLibraryOwnedItemId(entry, ownedItem);
    final localFront = ownedItemId == null
        ? null
        : ref
            .watch(
              localItemImageProvider((
                ownedItemId: ownedItemId,
                imageType: 'front_cover',
              )),
            )
            .value;
    final localBack = ownedItemId == null
        ? null
        : ref
            .watch(
              localItemImageProvider((
                ownedItemId: ownedItemId,
                imageType: 'back_cover',
              )),
            )
            .value;
    final db = ownedItemId == null ? null : ref.watch(localDatabaseProvider);
    final referenceLabel =
        libraryOwnedReferenceLabel(ownedItem, mediaType: entry.mediaType) ??
            entry.primaryReferenceLabel ??
            (entry.itemNumber?.trim().isNotEmpty == true
                ? '#${entry.itemNumber!.trim()}'
                : request.type.singularLabel.toUpperCase());
    final seriesTitle = entry.series?.seriesTitle?.trim();
    final editionLabel =
        entry.publishing?.subtitle?.trim().isNotEmpty == true
            ? entry.publishing!.subtitle!.trim()
            : entry.referenceFormatLabel?.trim().isNotEmpty == true
                ? entry.referenceFormatLabel!.trim()
                : entry.variant?.trim().isNotEmpty == true
                    ? entry.variant!.trim()
                    : 'Regular edition';
    final releaseLabel =
        formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString() ?? '-';
    final imprint = entry.publishing?.imprint?.trim();
    final publisherLabel = [
      if (entry.publisher?.trim().isNotEmpty == true) entry.publisher!.trim(),
      if (imprint != null && imprint.isNotEmpty) imprint,
    ].join(' / ');
    final synopsis = entry.synopsis?.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _kComicClzSurface,
        border: Border.all(color: _kComicClzBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final cover = SizedBox(
              width: wide ? 210 : 180,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF30363C), width: 0.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x25000000),
                      blurRadius: 8,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
                child: LibraryInteractiveCover(
                  title: entry.resolvedTitle,
                  itemNumber: entry.itemNumber,
                  imageUrl: entry.displayCoverUrl,
                  localBytes: localFront,
                  secondaryLocalBytes: localBack,
                  ownedItemId: ownedItemId,
                  accentColor: request.accent,
                  enableHoverCue: true,
                  onMissingSecondaryPressed: ownedItemId == null || db == null
                      ? null
                      : () async {
                          final savedType = await pickAndStoreOwnedItemImage(
                            context: context,
                            db: db,
                            ownedItemId: ownedItemId,
                            imageType: 'back_cover',
                          );
                          if (savedType == 'back_cover') {
                            ref.invalidate(
                              localItemImageProvider((
                                ownedItemId: ownedItemId,
                                imageType: 'back_cover',
                              )),
                            );
                          }
                        },
                ),
              ),
            );

            final summaryColumn = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (seriesTitle != null &&
                      seriesTitle.isNotEmpty &&
                      seriesTitle != entry.resolvedTitle) ...[
                    Text(
                      seriesTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: _kComicClzMuted,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    editionLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _kComicClzInk,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _ComicSummaryLine(label: 'Release', value: releaseLabel),
                  if (publisherLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      publisherLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _kComicClzInk,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                    ),
                  ],
                  if (imprint != null && imprint.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Imprint',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: _kComicClzMuted,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      imprint,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _kComicClzInk,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                  if (entry.barcode?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      entry.barcode!.trim(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _kComicClzInk,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find sold listings on eBay',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: request.accent,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                    Text(
                      'CLZ may be compensated for purchases made',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _kComicClzMuted,
                            height: 1.25,
                          ),
                    ),
                  ],
                ],
              ),
            );

            final descriptionBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: entry.isOwned
                          ? const Color(0xFF41B7DB)
                          : const Color(0xFFD0D7DE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        entry.isOwned ? Icons.check : Icons.remove,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Plot',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _kComicClzMuted,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  synopsis?.isNotEmpty == true ? synopsis! : 'No plot available.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _kComicClzInk,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            );

            final body = wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(width: 14),
                      summaryColumn,
                      const SizedBox(width: 18),
                      Expanded(child: descriptionBlock),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          cover,
                          const SizedBox(width: 12),
                          Expanded(child: summaryColumn),
                        ],
                      ),
                      const SizedBox(height: 14),
                      descriptionBlock,
                    ],
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.resolvedTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: request.accent,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ComicReferenceBadge(label: referenceLabel),
                  ],
                ),
                const SizedBox(height: 12),
                body,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ComicReferenceBadge extends StatelessWidget {
  const _ComicReferenceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF40464D), width: 1.6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _kComicClzInk,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _ComicSummaryLine extends StatelessWidget {
  const _ComicSummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _kComicClzInk,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/inspector/item_image_picker.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/book_author_spotlight.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryDetailHero extends StatelessWidget {
  const LibraryDetailHero({
    super.key,
    required this.type,
    required this.entry,
    required this.ownedItem,
    required this.accent,
    this.isOwned,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;
  final bool? isOwned;

  @override
  Widget build(BuildContext context) {
    final resolvedOwnedItemId = resolveLibraryOwnedItemId(entry, ownedItem);
    final resolvedIsOwned = isOwned ?? ownedItem != null || entry.isOwned;
    final referenceLabel =
        libraryOwnedReferenceLabel(ownedItem, mediaType: entry.mediaType) ??
            entry.primaryReferenceLabel;
    final releaseLabel =
        formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString();
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: accent.withValues(alpha: 0.6)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kAppField,
            Color.alphaBlend(
              accent.withValues(alpha: 0.18),
              kAppSurfaceSubtle,
            ),
            kAppField,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 680;
            final cover = Consumer(
              builder: (context, ref, _) {
                final ownedItemId = resolvedOwnedItemId;
                final db = ref.watch(localDatabaseProvider);
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
                return SizedBox(
                  width: wide ? 180 : 150,
                  child: LibraryInteractiveCover(
                    title: entry.resolvedTitle,
                    itemNumber: entry.itemNumber,
                    imageUrl: entry.displayCoverUrl,
                    localBase64: localFront,
                    secondaryLocalBase64: localBack,
                    ownedItemId: ownedItemId,
                    accentColor: accent,
                    onMissingSecondaryPressed: ownedItemId == null
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
                );
              },
            );
            final info = Column(
              crossAxisAlignment:
                  wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Text(
                  entry.resolvedTitle,
                  textAlign: wide ? TextAlign.start : TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    type.singularLabel,
                    if (entry.itemNumber != null &&
                        entry.itemNumber!.isNotEmpty)
                      '#${entry.itemNumber}',
                    if (entry.variant != null && entry.variant!.isNotEmpty)
                      entry.variant,
                    if (entry.publisher != null && entry.publisher!.isNotEmpty)
                      entry.publisher,
                    if (releaseLabel != null) releaseLabel,
                  ].whereType<String>().join(' | '),
                  textAlign: wide ? TextAlign.start : TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (entry.mediaType == 'book' &&
                    (entry.creators?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 12),
                  BookAuthorSpotlight(
                    creators: entry.creators!,
                    accent: accent,
                    centered: !wide,
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: wide ? WrapAlignment.start : WrapAlignment.center,
                  children: [
                    _DetailHeaderChip(
                      icon: Icons.inventory_2,
                      label: resolvedIsOwned ? 'Owned' : 'Not owned',
                      accent: accent,
                    ),
                    _DetailHeaderChip(
                      icon: entry.isWishlisted ? Icons.star : Icons.star_border,
                      label: entry.isWishlisted ? 'Wishlisted' : 'Wishlist',
                      accent: accent,
                    ),
                    if (referenceLabel != null)
                      _DetailHeaderChip(
                        icon: Icons.link_outlined,
                        label: referenceLabel,
                        accent: accent,
                      ),
                    if (entry.referenceFormatLabel != null)
                      _DetailHeaderChip(
                        icon: Icons.album_outlined,
                        label: 'Format: ${entry.referenceFormatLabel!}',
                        accent: accent,
                      ),
                    _DetailHeaderChip(
                      icon: entry.hasMissingCover
                          ? Icons.image_not_supported_outlined
                          : Icons.image_outlined,
                      label: entry.hasMissingCover
                          ? 'Missing cover'
                          : 'Cover ready',
                      accent: accent,
                    ),
                    _DetailHeaderChip(
                      icon: entry.hasMissingMetadata
                          ? Icons.manage_search
                          : Icons.fact_check_outlined,
                      label: entry.hasMissingMetadata
                          ? 'Missing metadata'
                          : 'Metadata ready',
                      accent: accent,
                    ),
                    if (ownedItem?.condition != null)
                      _DetailHeaderChip(
                        icon: Icons.fact_check_outlined,
                        label: ownedItem!.condition!,
                        accent: accent,
                      ),
                    if (ownedItem?.grade != null)
                      _DetailHeaderChip(
                        icon: Icons.workspace_premium,
                        label: ownedItem!.grade!,
                        accent: accent,
                      ),
                    if (entry.video?.runtimeMinutes != null)
                      _DetailHeaderChip(
                        icon: Icons.schedule,
                        label: '${entry.video!.runtimeMinutes} min',
                        accent: accent,
                      ),
                    if (entry.music?.trackCount != null)
                      _DetailHeaderChip(
                        icon: Icons.music_note,
                        label: '${entry.music!.trackCount} tracks',
                        accent: accent,
                      ),
                    if (entry.music?.releaseStatus != null)
                      _DetailHeaderChip(
                        icon: Icons.album,
                        label: entry.music!.releaseStatus!,
                        accent: accent,
                      ),
                    if (_detailPlatformLabel(entry.rawPlatforms)
                        case final platformLabel?)
                      _DetailHeaderChip(
                        icon: Icons.sports_esports,
                        label: platformLabel,
                        accent: accent,
                      ),
                    if (_detailNotesLabel(entry.notes) case final notesLabel?)
                      _DetailHeaderChip(
                        icon: Icons.sticky_note_2_outlined,
                        label: notesLabel,
                        accent: accent,
                      ),
                    if (ownedItem?.keyComic == true)
                      _DetailHeaderChip(
                        icon: Icons.label_important,
                        label: ownedItem!.keyReason ?? 'Key item',
                        accent: accent,
                      ),
                    if (ownedItem?.rawOrSlabbed != null ||
                        ownedItem?.gradingCompany != null)
                      _DetailHeaderChip(
                        icon: Icons.verified_outlined,
                        label: librarySlabMarkerLabel(
                              ownedItem?.rawOrSlabbed,
                              ownedItem?.gradingCompany,
                            ) ??
                            'Collector copy',
                        accent: accent,
                      ),
                  ],
                ),
                if (entry.synopsis != null &&
                    entry.synopsis!.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    entry.synopsis!,
                    maxLines: wide ? 5 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kAppTextMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ],
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cover,
                  const SizedBox(width: 18),
                  Expanded(child: info),
                ],
              );
            }
            return Column(
              children: [
                cover,
                const SizedBox(height: 14),
                info,
              ],
            );
          },
        ),
      ),
    );
  }
}

String? _detailPlatformLabel(List<String>? platforms) {
  if (platforms == null || platforms.isEmpty) {
    return null;
  }
  final values = platforms
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  if (values.isEmpty) {
    return null;
  }
  return values.join(', ');
}

String? _detailNotesLabel(String? notes) {
  final trimmed = notes?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  if (trimmed.length <= 48) {
    return trimmed;
  }
  return '${trimmed.substring(0, 47)}...';
}

class _DetailHeaderChip extends StatelessWidget {
  const _DetailHeaderChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryMetaChip(
      icon: icon,
      label: label,
      accent: accent,
      borderRadius: BorderRadius.circular(3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }
}

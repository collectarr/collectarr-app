import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class GenericLibraryDetailPage extends StatelessWidget {
  const GenericLibraryDetailPage({
    super.key,
    required this.type,
    required this.entry,
    required this.ownedItem,
    required this.accent,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kClzComicsTheme,
      child: Scaffold(
        backgroundColor: kClzCanvas,
        appBar: AppBar(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          title: Text(entry.title),
          actions: [
            IconButton(
              tooltip: entry.isWishlisted
                  ? 'Remove from wishlist'
                  : 'Move to wishlist',
              onPressed: entry.isWishlisted ? onRemoveWishlist : onAddWishlist,
              icon: Icon(entry.isWishlisted ? Icons.star : Icons.star_border),
            ),
            IconButton(
              tooltip: entry.isOwned
                  ? 'Remove from collection'
                  : 'Add to collection',
              onPressed: entry.isOwned ? onRemoveOwned : onAddOwned,
              icon: Icon(
                entry.isOwned
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DetailHero(
              type: type,
              entry: entry,
              ownedItem: ownedItem,
              accent: accent,
            ),
            const SizedBox(height: 12),
            _DetailActionStrip(
              type: type,
              entry: entry,
              onAddOwned: onAddOwned,
              onRemoveOwned: onRemoveOwned,
              onAddWishlist: onAddWishlist,
              onRemoveWishlist: onRemoveWishlist,
            ),
            const SizedBox(height: 16),
            _DetailStatsBar(entry: entry, ownedItem: ownedItem),
            const SizedBox(height: 16),
            _MetadataSection(type: type, entry: entry, accent: accent),
            _CoverStatusSection(entry: entry, accent: accent),
            _PersonalSection(
                entry: entry, ownedItem: ownedItem, accent: accent),
            _ProviderSection(type: type, accent: accent),
            _LocalSnapshotSection(entry: entry, ownedItem: ownedItem),
          ],
        ),
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({
    required this.type,
    required this.entry,
    required this.ownedItem,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final releaseLabel = formatNullableComicDate(entry.releaseDate) ??
        entry.releaseYear?.toString();
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: accent.withValues(alpha: 0.6)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF101010),
            Color.alphaBlend(
              accent.withValues(alpha: 0.18),
              const Color(0xFF18242A),
            ),
            const Color(0xFF101010),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 680;
            final cover = SizedBox(
              width: wide ? 180 : 150,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xAAFFFFFF)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xCC000000),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: LibraryCoverImage(
                    title: entry.title,
                    itemNumber: entry.itemNumber,
                    imageUrl: entry.displayCoverUrl,
                  ),
                ),
              ),
            );
            final info = Column(
              crossAxisAlignment:
                  wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Text(
                  entry.title,
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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: wide ? WrapAlignment.start : WrapAlignment.center,
                  children: [
                    _DetailChip(
                      icon: Icons.inventory_2,
                      label: entry.isOwned ? 'Owned' : 'Not owned',
                      accent: accent,
                    ),
                    _DetailChip(
                      icon: entry.isWishlisted ? Icons.star : Icons.star_border,
                      label: entry.isWishlisted ? 'Wishlisted' : 'Wishlist',
                      accent: accent,
                    ),
                    _DetailChip(
                      icon: entry.hasMissingCover
                          ? Icons.image_not_supported_outlined
                          : Icons.image_outlined,
                      label: entry.hasMissingCover
                          ? 'Missing cover'
                          : 'Cover ready',
                      accent: accent,
                    ),
                    _DetailChip(
                      icon: entry.hasMissingMetadata
                          ? Icons.manage_search
                          : Icons.fact_check_outlined,
                      label: entry.hasMissingMetadata
                          ? 'Missing metadata'
                          : 'Metadata ready',
                      accent: accent,
                    ),
                    if (ownedItem?.condition != null)
                      _DetailChip(
                        icon: Icons.fact_check_outlined,
                        label: ownedItem!.condition!,
                        accent: accent,
                      ),
                    if (ownedItem?.grade != null)
                      _DetailChip(
                        icon: Icons.workspace_premium,
                        label: ownedItem!.grade!,
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
                          color: kClzTextMuted,
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

class _DetailActionStrip extends StatelessWidget {
  const _DetailActionStrip({
    required this.type,
    required this.entry,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (entry.isOwned)
          FilledButton.icon(
            onPressed: onRemoveOwned,
            icon: const Icon(Icons.remove_circle_outline),
            label: Text('Remove ${type.singularLabel.toLowerCase()}'),
          )
        else
          FilledButton.icon(
            onPressed: onAddOwned,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add to collection'),
          ),
        OutlinedButton.icon(
          onPressed: entry.isWishlisted ? onRemoveWishlist : onAddWishlist,
          icon: Icon(entry.isWishlisted ? Icons.star : Icons.star_border),
          label: Text(
            entry.isWishlisted ? 'Remove from wishlist' : 'Move to wishlist',
          ),
        ),
      ],
    );
  }
}

class _DetailStatsBar extends StatelessWidget {
  const _DetailStatsBar({required this.entry, required this.ownedItem});

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DetailStat(label: 'Status', value: _statusLabel(entry)),
        _DetailStat(
          label: 'Cover',
          value: entry.hasMissingCover ? 'Missing' : 'Ready',
        ),
        _DetailStat(
          label: 'Metadata',
          value: entry.hasMissingMetadata ? 'Missing' : 'Ready',
        ),
        _DetailStat(
          label: 'Quantity',
          value: ownedItem == null ? '0' : ownedItem!.quantity.toString(),
        ),
        _DetailStat(
          label: 'Updated',
          value: formatNullableComicDate(entry.updatedAt) ?? '-',
        ),
      ],
    );
  }
}

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({
    required this.type,
    required this.entry,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryInspectorSection(
      title: 'Catalog metadata',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData('Kind', type.singularLabel),
            LibraryInspectorFactData('ID', entry.id),
            LibraryInspectorFactData('Title', entry.title),
            LibraryInspectorFactData('Number', _dash(entry.itemNumber)),
            LibraryInspectorFactData('Publisher', _dash(entry.publisher)),
            LibraryInspectorFactData(
              'Released',
              _dash(
                formatNullableComicDate(entry.releaseDate) ??
                    entry.releaseYear?.toString(),
              ),
            ),
            LibraryInspectorFactData('Variant', _dash(entry.variant)),
            LibraryInspectorFactData('Barcode', _dash(entry.barcode)),
          ],
        ),
      ],
    );
  }
}

class _CoverStatusSection extends StatelessWidget {
  const _CoverStatusSection({required this.entry, required this.accent});

  final LibraryWorkspaceEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryInspectorSection(
      title: 'Cover status',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData(
              'Display',
              entry.displayCoverUrl == null
                  ? 'Generated fallback'
                  : 'External URL',
            ),
            LibraryInspectorFactData(
              'Cover URL',
              entry.coverImageUrl == null ? '-' : 'Available',
            ),
            LibraryInspectorFactData(
              'Thumbnail URL',
              entry.thumbnailImageUrl == null ? '-' : 'Available',
            ),
          ],
        ),
        if (entry.coverImageUrl != null || entry.thumbnailImageUrl != null) ...[
          const SizedBox(height: 8),
          SelectableText(
            [
              if (entry.coverImageUrl != null) 'cover: ${entry.coverImageUrl}',
              if (entry.thumbnailImageUrl != null)
                'thumb: ${entry.thumbnailImageUrl}',
            ].join('\n'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kClzTextMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ],
    );
  }
}

class _PersonalSection extends StatelessWidget {
  const _PersonalSection({
    required this.entry,
    required this.ownedItem,
    required this.accent,
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final paid = formatComicMoney(entry.pricePaidCents, entry.currency);
    return LibraryInspectorSection(
      title: 'Local collection',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData('Status', _statusLabel(entry)),
            LibraryInspectorFactData('Owned ID', _dash(ownedItem?.id)),
            LibraryInspectorFactData('Condition', _dash(entry.condition)),
            LibraryInspectorFactData('Grade', _dash(entry.grade)),
            LibraryInspectorFactData(
              'Quantity',
              ownedItem == null ? '-' : ownedItem!.quantity.toString(),
            ),
            LibraryInspectorFactData('Storage', _dash(entry.storageBox)),
            LibraryInspectorFactData('Paid', paid.isEmpty ? '-' : paid),
            LibraryInspectorFactData(
              'Purchased',
              _dash(formatNullableComicDate(ownedItem?.purchaseDate)),
            ),
            LibraryInspectorFactData(
                'Read status', _dash(ownedItem?.readStatus)),
            LibraryInspectorFactData(
                'Rating', ownedItem?.rating?.toString() ?? '-'),
          ],
        ),
        if (ownedItem?.personalNotes != null &&
            ownedItem!.personalNotes!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorFact('Notes', ownedItem!.personalNotes!),
        ],
        if (ownedItem?.tags != null && ownedItem!.tags!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            values: [
              for (final tag in ownedItem!.tags!.split(','))
                if (tag.trim().isNotEmpty) tag.trim(),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProviderSection extends StatelessWidget {
  const _ProviderSection({required this.type, required this.accent});

  final LibraryTypeConfig type;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryInspectorSection(
      title: 'Providers',
      accentColor: accent,
      children: [
        if (type.supportedMetadataProviders.isEmpty)
          const Text(
            'No providers are registered for this media type yet. Manual local records still work and will sync as local snapshots.',
          )
        else ...[
          LibraryInspectorChipWrap(
            values: [
              for (final provider in type.supportedMetadataProviders)
                provider.id == type.defaultSupportedMetadataProvider
                    ? '${provider.label} default'
                    : provider.label,
            ],
          ),
          const SizedBox(height: 8),
          LibraryInspectorFactGrid(
            facts: [
              LibraryInspectorFactData(
                'Default provider',
                type.metadataProviderLabel(
                    type.defaultSupportedMetadataProvider),
              ),
              LibraryInspectorFactData(
                'Provider count',
                type.supportedMetadataProviders.length.toString(),
              ),
              LibraryInspectorFactData(
                'API keys',
                type.supportedMetadataProviders.any(
                  (provider) => provider.requiresApiKey,
                )
                    ? 'Some required'
                    : 'Not required',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Provider search depends on Collectarr Core being reachable. Local collection data remains available offline.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kClzTextMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
          for (final provider in type.supportedMetadataProviders)
            if (provider.usagePolicy != null) ...[
              const SizedBox(height: 8),
              Text(
                '${provider.label}: ${provider.usagePolicy!.summary}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kClzTextMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
        ],
      ],
    );
  }
}

class _LocalSnapshotSection extends StatelessWidget {
  const _LocalSnapshotSection({
    required this.entry,
    required this.ownedItem,
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;

  @override
  Widget build(BuildContext context) {
    return LibraryInspectorSection(
      title: 'Local snapshot',
      children: [
        SelectableText(
          [
            'catalog_id: ${entry.id}',
            'kind: ${entry.mediaType}',
            'owned_id: ${ownedItem?.id ?? '-'}',
            'edition_id: ${ownedItem?.editionId ?? '-'}',
            'variant_id: ${ownedItem?.variantId ?? '-'}',
            'updated_at: ${entry.updatedAt.toUtc().toIso8601String()}',
          ].join('\n'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: kClzTextMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC172E35),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: accent),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kClzPanelRaised,
        border: Border.all(color: kClzDivider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: kClzTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(LibraryWorkspaceEntry entry) {
  if (entry.isOwned) {
    return 'Owned';
  }
  if (entry.isWishlisted) {
    return 'Wishlist';
  }
  return 'Local catalog';
}

String _dash(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '-';
  }
  return value;
}

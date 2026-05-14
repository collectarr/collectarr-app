import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:collectarr_app/features/comics/metadata_correction_dialog.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/library_item_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicDetailPage extends ConsumerWidget {
  const ComicDetailPage({required this.item, super.key});

  final CatalogItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(comicDetailProvider(item.id));
    final libraryState = _libraryStateFor(
      ref.watch(shelfProvider).value,
      item.id,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            tooltip: 'Correct metadata',
            onPressed: () => showMetadataCorrectionDialog(
              context: context,
              ref: ref,
              item: item,
            ),
            icon: const Icon(Icons.fact_check_outlined),
          ),
        ],
      ),
      body: detail.when(
        data: (comic) => _ComicDetailBody(
          item: item,
          comic: comic,
          libraryState: libraryState,
        ),
        loading: () => _FallbackDetailBody(
          item: item,
          libraryState: libraryState,
          isLoading: true,
        ),
        error: (_, __) => _FallbackDetailBody(
          item: item,
          libraryState: libraryState,
        ),
      ),
    );
  }

  LibraryItemState _libraryStateFor(ShelfState? shelf, String itemId) {
    for (final entry in shelf?.entries ?? const <ShelfEntry>[]) {
      if (entry.itemId == itemId) {
        return LibraryItemState(
          ownedItem: entry.ownedItem,
          isWishlisted: entry.wishlistItem != null,
        );
      }
    }
    return const LibraryItemState();
  }
}

class _ComicDetailBody extends ConsumerWidget {
  const _ComicDetailBody({
    required this.item,
    required this.comic,
    required this.libraryState,
  });

  final CatalogItem item;
  final ComicDetail comic;
  final LibraryItemState libraryState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final edition = comic.primaryEdition;
    final variant = comic.primaryVariant;
    final variantsCount = comic.editions.fold<int>(
      0,
      (total, edition) => total + edition.variants.length,
    );
    final releasesCount = comic.editions.fold<int>(
      0,
      (total, edition) => total + edition.releases.length,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DetailHeader(
          title: comic.title,
          subtitle: [
            if (comic.itemNumber != null) '#${comic.itemNumber}',
            if (comic.publisher != null) comic.publisher,
            libraryState.statusLabel,
          ].join(' | '),
          coverUrl: comic.displayCoverUrl,
          chips: [
            comic.kind,
            if (edition?.format != null) edition!.format!,
            if (edition?.releaseDate != null) _dateLabel(edition!.releaseDate!),
            if (comic.pageCount != null) '${comic.pageCount} pages',
            if (comic.barcode != null) comic.barcode!,
          ],
        ),
        const SizedBox(height: 12),
        _DetailStatsBar(
          stats: [
            ('Editions', comic.editions.length.toString()),
            ('Variants', variantsCount.toString()),
            ('Releases', releasesCount.toString()),
            ('Creators', comic.creators.length.toString()),
            ('Characters', comic.characters.length.toString()),
          ],
        ),
        const SizedBox(height: 16),
        _MetadataSection(
          title: 'Catalog',
          children: [
            _InfoGrid(
              rows: [
                ('Series', comic.seriesTitle),
                ('Volume', comic.volumeName),
                ('Volume Year', comic.volumeStartYear?.toString()),
                ('Cover Date', _optionalDateLabel(comic.coverDate)),
                ('Store Date', _optionalDateLabel(comic.storeDate)),
                ('Barcode', comic.barcode),
                (
                  'Cover Price',
                  _moneyLabel(comic.coverPriceCents, comic.currency)
                ),
              ],
            ),
          ],
        ),
        _LocalStatusSection(libraryState: libraryState),
        if (variant != null)
          _MetadataSection(
            title: 'Primary variant',
            children: [
              _InfoGrid(
                rows: [
                  ('Name', variant.name),
                  ('Type', variant.variantType),
                  ('Region', variant.region),
                  ('SKU', variant.sku),
                  ('Barcode', variant.barcode),
                  ('ISBN', variant.isbn),
                  (
                    'Cover Price',
                    _moneyLabel(variant.coverPriceCents, variant.currency)
                  ),
                  ('Description', variant.description),
                ],
              ),
            ],
          ),
        if (comic.synopsis != null) ...[
          const SizedBox(height: 16),
          Text(comic.synopsis!),
        ],
        if (comic.providerLinks.isNotEmpty)
          _MetadataSection(
            title: 'Provider links',
            children: [
              for (final link in comic.providerLinks)
                SelectableText(
                  [
                    link.provider,
                    link.entityType,
                    link.providerItemId,
                    link.siteUrl ?? link.apiUrl,
                  ].whereType<String>().join(' - '),
                ),
            ],
          ),
        if (comic.creators.isNotEmpty)
          _MetadataSection(
            title: 'Creators',
            children: [_CreditWrap(credits: comic.creators)],
          ),
        if (comic.characters.isNotEmpty)
          _MetadataSection(
            title: 'Characters',
            children: [_CreditWrap(credits: comic.characters)],
          ),
        if (comic.storyArcs.isNotEmpty)
          _MetadataSection(
            title: 'Story arcs',
            children: [_CreditWrap(credits: comic.storyArcs)],
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => showMetadataCorrectionDialog(
            context: context,
            ref: ref,
            item: item,
          ),
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Suggest metadata correction'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () async {
            await ref.read(collectionMutationsProvider).addItem(
                  comic.id,
                  editionId: edition?.id,
                  variantId: variant?.id,
                  condition: 'Near Mint',
                  grade: 'Ungraded',
                );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to local collection')),
              );
            }
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add primary variant to collection'),
        ),
        const SizedBox(height: 24),
        Text('Editions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final item in comic.editions) _EditionPanel(edition: item),
      ],
    );
  }

  String _dateLabel(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  String? _optionalDateLabel(DateTime? value) =>
      value == null ? null : _dateLabel(value);

  String? _moneyLabel(int? cents, String? currency) {
    if (cents == null) {
      return null;
    }
    final sign = cents < 0 ? '-' : '';
    final absolute = cents.abs();
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '${currency ?? ''} $sign$whole.$fraction'.trim();
  }
}

class _FallbackDetailBody extends ConsumerWidget {
  const _FallbackDetailBody({
    required this.item,
    required this.libraryState,
    this.isLoading = false,
  });

  final CatalogItem item;
  final LibraryItemState libraryState;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DetailHeader(
          title: item.title,
          subtitle: [
            if (item.itemNumber != null) '#${item.itemNumber}',
            if (item.publisher != null) item.publisher,
            libraryState.statusLabel,
          ].join(' | '),
          coverUrl: item.displayCoverUrl,
          chips: [
            item.kind,
            if (item.releaseDate != null) _dateLabel(item.releaseDate!),
            if (item.barcode != null) item.barcode!,
          ],
        ),
        if (isLoading) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ],
        _LocalStatusSection(libraryState: libraryState),
        if (item.synopsis != null) ...[
          const SizedBox(height: 12),
          Text(item.synopsis!),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => showMetadataCorrectionDialog(
            context: context,
            ref: ref,
            item: item,
          ),
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Suggest metadata correction'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () async {
            await ref.read(collectionMutationsProvider).addItem(item.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to local collection')),
              );
            }
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add to collection'),
        ),
      ],
    );
  }

  String _dateLabel(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.title,
    required this.subtitle,
    required this.coverUrl,
    required this.chips,
  });

  final String title;
  final String subtitle;
  final String? coverUrl;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final cover = SizedBox(
      width: wide ? 180 : 128,
      child: _DetailCover(url: coverUrl),
    );
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.titleSmall),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final chip in chips)
              if (chip.trim().isNotEmpty) _MetadataChip(label: chip),
          ],
        ),
      ],
    );
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cover,
          const SizedBox(height: 16),
          info,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cover,
        const SizedBox(width: 20),
        Expanded(child: info),
      ],
    );
  }
}

class _DetailStatsBar extends StatelessWidget {
  const _DetailStatsBar({required this.stats});

  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final stat in stats)
          Container(
            width: 112,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.$2,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  stat.$1,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LocalStatusSection extends StatelessWidget {
  const _LocalStatusSection({required this.libraryState});

  final LibraryItemState libraryState;

  @override
  Widget build(BuildContext context) {
    final owned = libraryState.ownedItem;
    return _MetadataSection(
      title: 'Local status',
      children: [
        _InfoGrid(
          rows: [
            ('Shelf', libraryState.statusLabel),
            ('Condition', owned?.condition),
            ('Grade', owned?.grade),
            ('Quantity', owned?.quantity.toString()),
            ('Storage Box', owned?.storageBox),
            ('Read Status', owned?.readStatus),
            ('Rating', owned?.rating?.toString()),
            ('Tags', owned?.tags),
            ('Signed By', owned?.signedBy),
            ('Notes', owned?.personalNotes),
          ],
        ),
      ],
    );
  }
}

class _EditionPanel extends StatelessWidget {
  const _EditionPanel({required this.edition});

  final ComicEdition edition;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(edition.title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (edition.format != null)
                  _MetadataChip(label: edition.format!),
                if (edition.publisher != null)
                  _MetadataChip(label: edition.publisher!),
                if (edition.language != null)
                  _MetadataChip(label: edition.language!),
                if (edition.region != null)
                  _MetadataChip(label: edition.region!),
                if (edition.upc != null)
                  _MetadataChip(label: 'UPC ${edition.upc!}'),
                if (edition.isbn != null)
                  _MetadataChip(label: 'ISBN ${edition.isbn!}'),
              ],
            ),
            if (edition.variants.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Variants', style: Theme.of(context).textTheme.labelLarge),
              for (final variant in edition.variants)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    variant.isPrimary ? Icons.check_circle : Icons.album,
                  ),
                  title: Text(variant.name),
                  subtitle: Text(
                    [
                      variant.variantType,
                      variant.sku,
                      variant.barcode,
                      _moneyLabel(variant.coverPriceCents, variant.currency),
                    ].whereType<String>().join(' - '),
                  ),
                ),
            ],
            if (edition.releases.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Releases', style: Theme.of(context).textTheme.labelLarge),
              for (final release in edition.releases)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.public),
                  title: Text(release.region),
                  subtitle: Text(
                    [
                      if (release.publisher != null) release.publisher,
                      if (release.releaseDate != null)
                        _dateLabel(release.releaseDate!),
                    ].whereType<String>().join(' - '),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  String? _moneyLabel(int? cents, String? currency) {
    if (cents == null) {
      return null;
    }
    final sign = cents < 0 ? '-' : '';
    final absolute = cents.abs();
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '${currency ?? ''} $sign$whole.$fraction'.trim();
  }
}

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.rows});

  final List<(String, String?)> rows;

  @override
  Widget build(BuildContext context) {
    final visibleRows = rows.where((row) {
      final value = row.$2;
      return value != null && value.isNotEmpty;
    }).toList(growable: false);
    if (visibleRows.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        for (final row in visibleRows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 112,
                  child: Text(
                    row.$1,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Expanded(child: SelectableText(row.$2!)),
              ],
            ),
          ),
      ],
    );
  }
}

class _CreditWrap extends StatelessWidget {
  const _CreditWrap({required this.credits});

  final List<ComicCredit> credits;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final credit in credits)
          _MetadataChip(
            label: credit.role == null
                ? credit.name
                : '${credit.name} - ${credit.role}',
          ),
      ],
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _DetailCover extends StatelessWidget {
  const _DetailCover({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Icon(Icons.menu_book, size: 64)),
    );
    final imageUrl = url;
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: imageUrl == null || imageUrl.isEmpty
          ? placeholder
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: kIsWeb
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      loadingBuilder: (context, child, loadingProgress) {
                        return loadingProgress == null ? child : placeholder;
                      },
                      errorBuilder: (_, __, ___) => placeholder,
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => placeholder,
                      errorWidget: (_, __, ___) => placeholder,
                    ),
            ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:collectarr_app/features/comics/metadata_correction_dialog.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicDetailPage extends ConsumerWidget {
  const ComicDetailPage({required this.item, super.key});

  final CatalogItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(comicDetailProvider(item.id));
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
        data: (comic) => _ComicDetailBody(item: item, comic: comic),
        loading: () => _FallbackDetailBody(item: item, isLoading: true),
        error: (_, __) => _FallbackDetailBody(item: item),
      ),
    );
  }
}

class _ComicDetailBody extends ConsumerWidget {
  const _ComicDetailBody({required this.item, required this.comic});

  final CatalogItem item;
  final ComicDetail comic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final edition = comic.primaryEdition;
    final variant = comic.primaryVariant;
    final source = edition?.sourceMetadata;
    final providerUrl = source?['site_detail_url']?.toString();
    final creators = _metadataNames(source, 'person_credits');
    final characters = _metadataNames(source, 'character_credits');
    final arcs = _metadataNames(source, 'story_arc_credits');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DetailCover(url: comic.displayCoverUrl),
        const SizedBox(height: 16),
        Text(comic.title, style: Theme.of(context).textTheme.headlineSmall),
        if (comic.itemNumber != null) Text('#${comic.itemNumber}'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetadataChip(label: comic.kind),
            if (edition?.publisher != null)
              _MetadataChip(label: edition!.publisher!),
            if (edition?.format != null) _MetadataChip(label: edition!.format!),
            if (edition?.releaseDate != null)
              _MetadataChip(label: _dateLabel(edition!.releaseDate!)),
          ],
        ),
        if (comic.synopsis != null) ...[
          const SizedBox(height: 16),
          Text(comic.synopsis!),
        ],
        if (providerUrl != null) ...[
          const SizedBox(height: 16),
          _MetadataSection(
            title: 'Provider links',
            children: [SelectableText(providerUrl)],
          ),
        ],
        if (creators.isNotEmpty)
          _MetadataSection(
            title: 'Creators',
            children: [_NameWrap(names: creators)],
          ),
        if (characters.isNotEmpty)
          _MetadataSection(
            title: 'Characters',
            children: [_NameWrap(names: characters)],
          ),
        if (arcs.isNotEmpty)
          _MetadataSection(
            title: 'Story arcs',
            children: [_NameWrap(names: arcs)],
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

  List<String> _metadataNames(Map<String, dynamic>? source, String key) {
    final values = source?[key];
    if (values is! List) {
      return const [];
    }
    return [
      for (final value in values)
        if (value is Map && value['name'] != null) value['name'].toString(),
    ];
  }
}

class _FallbackDetailBody extends ConsumerWidget {
  const _FallbackDetailBody({required this.item, this.isLoading = false});

  final CatalogItem item;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DetailCover(url: item.displayCoverUrl),
        const SizedBox(height: 16),
        Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
        if (item.itemNumber != null) Text('#${item.itemNumber}'),
        if (isLoading) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ],
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
                if (edition.upc != null)
                  _MetadataChip(label: 'UPC ${edition.upc!}'),
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
                  subtitle: variant.sku == null ? null : Text(variant.sku!),
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

class _NameWrap extends StatelessWidget {
  const _NameWrap({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final name in names) _MetadataChip(label: name),
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
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => placeholder,
                errorWidget: (_, __, ___) => placeholder,
              ),
            ),
    );
  }
}

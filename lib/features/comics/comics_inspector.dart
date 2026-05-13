import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/comics/comic_detail_page.dart';
import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:collectarr_app/features/comics/metadata_correction_dialog.dart';
import 'package:collectarr_app/features/comics/owned_comic_edit_dialog.dart';
import 'package:collectarr_app/features/library/library_item_state.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color _kClzAccent = Color(0xFF10A8D8);
const Color _kClzYellow = Color(0xFFFFD400);
const Color _kClzDivider = Color(0xFF4A4A4A);
const Color _kClzTextMuted = Color(0xFFB8B8B8);

class LibraryAwareComicInspector extends ConsumerWidget {
  const LibraryAwareComicInspector({super.key, required this.item});

  final CatalogItem? item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = _watchWishlistIds(ref);
    return ComicInspector(
      item: item,
      libraryState: libraryItemStateFor(
        item: item,
        ownedByItemId: ownedByItemId,
        wishlistIds: wishlistIds,
      ),
    );
  }
}

class ComicInspector extends ConsumerWidget {
  const ComicInspector({
    super.key,
    required this.item,
    required this.libraryState,
  });

  final CatalogItem? item;
  final LibraryItemState libraryState;

  static const conditions = [
    'Near Mint',
    'Very Fine',
    'Fine',
    'Good',
    'Poor',
  ];

  static const grades = [
    'Ungraded',
    '10.0',
    '9.8',
    '9.6',
    '9.4',
    '9.0',
    '8.0',
    '7.0',
    '6.0',
    '5.0',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedItem = libraryState.ownedItem;
    final isOwned = ownedItem != null;
    final detail =
        item == null ? null : ref.watch(comicDetailProvider(item!.id));
    if (item == null) {
      return const _EmptyInspector();
    }
    return Stack(
      children: [
        Positioned.fill(child: _InspectorBackdrop(item: item!)),
        DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xBA111111)),
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              _InspectorActionBar(
                isOwned: isOwned,
                isWishlisted: libraryState.isWishlisted,
                onEdit: ownedItem == null
                    ? null
                    : () => _showEditDialog(context, ref, item!, ownedItem),
                onWishlist: () => _toggleWishlist(context, ref, item!),
                onOpenDetails: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ComicDetailPage(item: item!),
                  ),
                ),
                onCorrectMetadata: () => showMetadataCorrectionDialog(
                  context: context,
                  ref: ref,
                  item: item!,
                ),
              ),
              const SizedBox(height: 7),
              _InspectorHero(item: item!, libraryState: libraryState),
              const SizedBox(height: 10),
              _CollectionFields(
                enabled: isOwned,
                condition: ownedItem?.condition,
                grade: ownedItem?.grade,
                conditions: conditions,
                grades: grades,
                onConditionChanged: ownedItem == null
                    ? null
                    : (value) => _updateCollection(
                          context,
                          ref,
                          ownedItem,
                          condition: value,
                          grade: ownedItem.grade,
                        ),
                onGradeChanged: ownedItem == null
                    ? null
                    : (value) => _updateCollection(
                          context,
                          ref,
                          ownedItem,
                          condition: ownedItem.condition,
                          grade: value,
                        ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ComicDetailPage(item: item!),
                  ),
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open comic details'),
              ),
              const SizedBox(height: 7),
              if (isOwned)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    FilledButton.icon(
                      onPressed: () =>
                          _showEditDialog(context, ref, item!, ownedItem),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _moveToWishlist(
                        context,
                        ref,
                        item!,
                        ownedItem,
                      ),
                      icon: const Icon(Icons.star_border),
                      label: const Text('Move to wishlist'),
                    ),
                    FilledButton.icon(
                      onPressed: () =>
                          _removeFromCollection(context, ref, ownedItem),
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text('Remove'),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _addToCollection(context, ref, item!),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add to collection'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _toggleWishlist(context, ref, item!),
                      icon: Icon(
                        libraryState.isWishlisted
                            ? Icons.star
                            : Icons.star_border,
                      ),
                      label: Text(
                        libraryState.isWishlisted
                            ? 'Remove from wishlist'
                            : 'Move to wishlist',
                      ),
                    ),
                  ],
                ),
              if (ownedItem != null) ...[
                const SizedBox(height: 10),
                _PersonalDetailsEditor(ownedItem: ownedItem),
              ],
              if (item!.synopsis != null) ...[
                const SizedBox(height: 10),
                LibraryInspectorSection(
                  title: 'Plot',
                  children: [
                    Text(
                      item!.synopsis!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              _RichMetadataInspector(
                item: item!,
                detail: detail,
                libraryState: libraryState,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    CatalogItem item,
    OwnedItem ownedItem,
  ) async {
    final selection = await showDialog<OwnedComicEditSelection>(
      context: context,
      builder: (context) => OwnedComicEditDialog(
        item: item,
        ownedItem: ownedItem,
        conditions: conditions,
        grades: grades,
        cover: _CoverImage(item: item),
      ),
    );
    if (selection == null) {
      return;
    }
    await ref.read(collectionMutationsProvider).updateItem(
          ownedItem,
          condition: selection.condition,
          grade: selection.grade,
          purchaseDate: selection.purchaseDate,
          pricePaidCents: selection.pricePaidCents,
          currency: selection.currency,
          personalNotes: selection.personalNotes,
          quantity: selection.quantity,
          storageBox: selection.storageBox,
          indexNumber: selection.indexNumber,
          coverPriceCents: selection.coverPriceCents,
          rawOrSlabbed: selection.rawOrSlabbed,
          gradingCompany: selection.gradingCompany,
          graderNotes: selection.graderNotes,
          signedBy: selection.signedBy,
          keyComic: selection.keyComic,
          keyReason: selection.keyReason,
          rating: selection.rating,
          readStatus: selection.readStatus,
          tags: selection.tags,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comic details updated')),
      );
    }
  }

  Future<void> _addToCollection(
      BuildContext context, WidgetRef ref, CatalogItem item) async {
    await ref.read(collectionMutationsProvider).addItem(
          item.id,
          condition: 'Near Mint',
          grade: 'Ungraded',
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to local collection')),
      );
    }
  }

  Future<void> _updateCollection(
    BuildContext context,
    WidgetRef ref,
    OwnedItem ownedItem, {
    required String? condition,
    required String? grade,
  }) async {
    await ref.read(collectionMutationsProvider).updateItem(
          ownedItem,
          condition: condition,
          grade: grade,
          purchaseDate: ownedItem.purchaseDate,
          pricePaidCents: ownedItem.pricePaidCents,
          currency: ownedItem.currency,
          personalNotes: ownedItem.personalNotes,
          quantity: ownedItem.quantity,
          storageBox: ownedItem.storageBox,
          indexNumber: ownedItem.indexNumber,
          coverPriceCents: ownedItem.coverPriceCents,
          rawOrSlabbed: ownedItem.rawOrSlabbed,
          gradingCompany: ownedItem.gradingCompany,
          graderNotes: ownedItem.graderNotes,
          signedBy: ownedItem.signedBy,
          keyComic: ownedItem.keyComic,
          keyReason: ownedItem.keyReason,
          rating: ownedItem.rating,
          readStatus: ownedItem.readStatus,
          tags: ownedItem.tags,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection details updated')),
      );
    }
  }

  Future<void> _removeFromCollection(
      BuildContext context, WidgetRef ref, OwnedItem ownedItem) async {
    await ref.read(collectionMutationsProvider).removeItem(ownedItem);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from local collection')),
      );
    }
  }

  Future<void> _moveToWishlist(
    BuildContext context,
    WidgetRef ref,
    CatalogItem item,
    OwnedItem ownedItem,
  ) async {
    await ref.read(collectionMutationsProvider).addToWishlist(item.id);
    await ref.read(collectionMutationsProvider).removeItem(ownedItem);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Moved to local wishlist')),
      );
    }
  }

  Future<void> _toggleWishlist(
      BuildContext context, WidgetRef ref, CatalogItem item) async {
    await ref.read(collectionMutationsProvider).toggleWishlist(item.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            libraryState.isWishlisted
                ? 'Removed from local wishlist'
                : 'Saved to local wishlist',
          ),
        ),
      );
    }
  }
}

class _InspectorBackdrop extends StatelessWidget {
  const _InspectorBackdrop({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.42,
          child: _CoverImage(item: item),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x66111111),
                Color(0xE0121212),
                Color(0xFA111111),
              ],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xF0101010),
                Color(0xC0101010),
                Color(0xE8101010),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InspectorActionBar extends StatelessWidget {
  const _InspectorActionBar({
    required this.isOwned,
    required this.isWishlisted,
    required this.onEdit,
    required this.onWishlist,
    required this.onOpenDetails,
    required this.onCorrectMetadata,
  });

  final bool isOwned;
  final bool isWishlisted;
  final VoidCallback? onEdit;
  final VoidCallback onWishlist;
  final VoidCallback onOpenDetails;
  final VoidCallback onCorrectMetadata;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD51D1D1D),
        border: Border.all(color: _kClzDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Row(
          children: [
            _InspectorActionButton(
              tooltip: 'Edit comic',
              onPressed: onEdit,
              icon: Icons.edit,
            ),
            const SizedBox(width: 4),
            _InspectorActionButton(
              tooltip: 'Wishlist',
              onPressed: onWishlist,
              icon: isWishlisted ? Icons.star : Icons.star_border,
            ),
            const SizedBox(width: 4),
            _InspectorActionButton(
              tooltip: 'Open details',
              onPressed: onOpenDetails,
              icon: Icons.open_in_new,
            ),
            const SizedBox(width: 4),
            _InspectorActionButton(
              tooltip: 'Correct metadata',
              onPressed: onCorrectMetadata,
              icon: Icons.fact_check_outlined,
            ),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: isOwned ? _kClzYellow : const Color(0xFF2A2A2A),
                border: Border.all(
                  color: isOwned ? _kClzYellow : _kClzDivider,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isOwned ? Icons.check : Icons.check_box_outline_blank,
                      size: 15,
                      color: isOwned ? const Color(0xFF141414) : _kClzTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOwned ? 'OWNED' : 'LOCAL',
                      style: TextStyle(
                        color:
                            isOwned ? const Color(0xFF141414) : _kClzTextMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InspectorActionButton extends StatelessWidget {
  const _InspectorActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 28,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

class _InspectorHero extends StatelessWidget {
  const _InspectorHero({required this.item, required this.libraryState});

  final CatalogItem item;
  final LibraryItemState libraryState;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 560;
        final cover = SizedBox(
          width: wide ? 146 : 174,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xAAFFFFFF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xCC000000),
                    blurRadius: 16,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: _CoverImage(item: item),
            ),
          ),
        );
        final info = _InspectorHeroInfo(
          item: item,
          libraryState: libraryState,
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x884DBBD5)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xD70A0A0A),
                Color(0xB3132830),
                Color(0xE80A0A0A),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(width: 14),
                      Expanded(child: info),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      cover,
                      const SizedBox(height: 10),
                      info,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _InspectorHeroInfo extends StatelessWidget {
  const _InspectorHeroInfo({required this.item, required this.libraryState});

  final CatalogItem item;
  final LibraryItemState libraryState;

  @override
  Widget build(BuildContext context) {
    final ownedItem = libraryState.ownedItem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _kClzAccent,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
              ),
            ),
            if (item.itemNumber != null) ...[
              const SizedBox(width: 7),
              _IssuePill(label: '#${item.itemNumber}'),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Text(
          [
            if (item.variant != null && item.variant!.isNotEmpty) item.variant,
            if (item.publisher != null && item.publisher!.isNotEmpty)
              item.publisher,
            if (item.releaseDate != null) _formatDate(item.releaseDate!),
          ].whereType<String>().join('  |  '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _MetaChip(
              icon: Icons.inventory_2,
              label: libraryState.isOwned ? 'Owned' : 'Not owned',
            ),
            _MetaChip(
              icon: libraryState.isWishlisted ? Icons.star : Icons.star_border,
              label: libraryState.isWishlisted ? 'Wishlisted' : 'Wishlist',
            ),
            _MetaChip(
              icon: Icons.workspace_premium,
              label: ownedItem?.grade ?? 'Ungraded',
            ),
            if (ownedItem?.condition != null)
              _MetaChip(
                icon: Icons.fact_check_outlined,
                label: ownedItem!.condition!,
              ),
            if (ownedItem?.pricePaidCents != null)
              _MetaChip(
                icon: Icons.attach_money,
                label: _formatOptionalMoney(
                  ownedItem!.pricePaidCents,
                  ownedItem.currency,
                ),
              ),
          ],
        ),
        if (item.barcode != null && item.barcode!.isNotEmpty) ...[
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xAA151515),
              border: Border.all(color: const Color(0x4437C7E8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                children: [
                  const Icon(Icons.view_week_outlined, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.barcode!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            letterSpacing: 1.1,
                            color: _kClzTextMuted,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RichMetadataInspector extends StatelessWidget {
  const _RichMetadataInspector({
    required this.item,
    required this.detail,
    required this.libraryState,
  });

  final CatalogItem item;
  final AsyncValue<ComicDetail>? detail;
  final LibraryItemState libraryState;

  @override
  Widget build(BuildContext context) {
    final owned = libraryState.ownedItem;
    final detailValue = detail?.value;
    final edition = detailValue?.primaryEdition;
    final variant = detailValue?.primaryVariant;
    final source = edition?.sourceMetadata;
    final creators = _creditFacts(
      detailValue?.creators ?? const [],
      fallbackValues: _metadataNames(source, 'person_credits'),
    );
    final characters = _creditNames(
      detailValue?.characters ?? const [],
      fallbackValues: _metadataNames(source, 'character_credits'),
    );
    final arcs = _creditNames(
      detailValue?.storyArcs ?? const [],
      fallbackValues: _metadataNames(source, 'story_arc_credits'),
    );
    final providerFacts = _providerFacts(detailValue, edition);
    final releaseFacts = _releaseFacts(edition);
    final variantFacts = _variantFacts(variant);
    final tracking = owned?.mediaTracking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LibraryInspectorSection(
          title: 'Product Details',
          children: [
            LibraryInspectorFact(
              'Series',
              detailValue?.seriesTitle ?? detailValue?.volumeName ?? item.title,
            ),
            LibraryInspectorFact(
                'Publisher', edition?.publisher ?? item.publisher ?? '-'),
            LibraryInspectorFact(
              'Release',
              _formatNullableDate(
                    edition?.releaseDate ??
                        detailValue?.storeDate ??
                        item.releaseDate,
                  ) ??
                  '-',
            ),
            LibraryInspectorFact(
              'Cover date',
              _formatNullableDate(detailValue?.coverDate) ?? '-',
            ),
            LibraryInspectorFact('Format', edition?.format ?? item.kind),
            LibraryInspectorFact(
                'UPC / ISBN', edition?.upc ?? edition?.isbn ?? '-'),
            LibraryInspectorFact(
              'Pages / Price',
              [
                if (detailValue?.pageCount != null)
                  '${detailValue!.pageCount} pages',
                _formatOptionalMoney(
                  detailValue?.coverPriceCents ?? variant?.coverPriceCents,
                  detailValue?.currency ?? variant?.currency,
                ),
              ].where((value) => value.isNotEmpty).join(' | ').ifEmpty('-'),
            ),
          ],
        ),
        if (variantFacts.isNotEmpty || releaseFacts.isNotEmpty)
          LibraryInspectorSection(
            title: 'Edition',
            children: [
              for (final fact in variantFacts)
                LibraryInspectorFact(fact.label, fact.value),
              if (releaseFacts.isNotEmpty) ...[
                const SizedBox(height: 4),
                LibraryInspectorChipWrap(values: releaseFacts),
              ],
            ],
          ),
        LibraryInspectorSection(
          title: 'Personal',
          children: [
            LibraryInspectorFactGrid(
              facts: [
                LibraryInspectorFactData(
                    'Quantity', owned?.quantity.toString() ?? '-'),
                LibraryInspectorFactData(
                    'Storage box', owned?.storageBox ?? '-'),
                LibraryInspectorFactData(
                    'Index', owned?.indexNumber?.toString() ?? '-'),
                LibraryInspectorFactData(
                    'Tracking', tracking?.statusLabel ?? '-'),
                LibraryInspectorFactData(
                    'Rating', tracking?.rating?.toString() ?? '-'),
                LibraryInspectorFactData(
                    'Read status', owned?.readStatus ?? '-'),
                LibraryInspectorFactData('Tags', owned?.tags ?? '-'),
              ],
            ),
            if (owned?.signedBy != null && owned!.signedBy!.isNotEmpty)
              LibraryInspectorFact('Signed by', owned.signedBy!),
          ],
        ),
        LibraryInspectorSection(
          title: 'Value',
          children: [
            LibraryInspectorFactGrid(
              facts: [
                LibraryInspectorFactData(
                  'Purchase',
                  _formatOptionalMoney(
                    owned?.pricePaidCents,
                    owned?.currency,
                  ).ifEmpty('-'),
                ),
                LibraryInspectorFactData(
                  'Cover price',
                  _formatOptionalMoney(
                    owned?.coverPriceCents,
                    owned?.currency,
                  ).ifEmpty('-'),
                ),
                LibraryInspectorFactData(
                    'Grade status', owned?.rawOrSlabbed ?? '-'),
                LibraryInspectorFactData(
                  'Grading company',
                  owned?.gradingCompany ?? '-',
                ),
                LibraryInspectorFactData(
                  'Key issue',
                  owned?.keyComic == true ? 'Yes' : 'No',
                ),
              ],
            ),
            if (owned?.keyReason != null && owned!.keyReason!.isNotEmpty)
              LibraryInspectorFact('Key reason', owned.keyReason!),
          ],
        ),
        if (creators.isNotEmpty)
          LibraryInspectorSection(
            title: 'Creators',
            children: [
              for (final fact in creators.take(8))
                LibraryInspectorFact(fact.label, fact.value),
            ],
          ),
        if (characters.isNotEmpty)
          LibraryInspectorChipSection(title: 'Characters', values: characters),
        if (arcs.isNotEmpty)
          LibraryInspectorChipSection(title: 'Story arcs', values: arcs),
        if (providerFacts.isNotEmpty)
          LibraryInspectorSection(
            title: 'Provider Links',
            children: [
              for (final fact in providerFacts)
                LibraryInspectorFact(fact.label, fact.value),
            ],
          ),
        if (detail?.isLoading ?? false)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
      ],
    );
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

  List<LibraryInspectorFactData> _creditFacts(
    List<ComicCredit> credits, {
    required List<String> fallbackValues,
  }) {
    if (credits.isEmpty) {
      return [
        for (final value in fallbackValues)
          LibraryInspectorFactData('Creator', value),
      ];
    }
    final byRole = <String, List<String>>{};
    for (final credit in credits) {
      final role = (credit.role == null || credit.role!.isEmpty)
          ? 'Creator'
          : credit.role!;
      byRole.putIfAbsent(role, () => []).add(credit.name);
    }
    return [
      for (final entry in byRole.entries)
        LibraryInspectorFactData(entry.key, entry.value.take(4).join(', ')),
    ];
  }

  List<String> _creditNames(
    List<ComicCredit> credits, {
    required List<String> fallbackValues,
  }) {
    if (credits.isEmpty) {
      return fallbackValues;
    }
    return [
      for (final credit in credits) credit.name,
    ];
  }

  List<LibraryInspectorFactData> _variantFacts(ComicVariant? variant) {
    if (variant == null) {
      return const [];
    }
    return [
      LibraryInspectorFactData('Variant cover', variant.name),
      if (variant.variantType != null)
        LibraryInspectorFactData('Variant type', variant.variantType!),
      if (variant.region != null)
        LibraryInspectorFactData('Region', variant.region!),
      if (variant.barcode != null)
        LibraryInspectorFactData('Barcode', variant.barcode!),
      if (variant.description != null && variant.description!.isNotEmpty)
        LibraryInspectorFactData('Description', variant.description!),
    ];
  }

  List<String> _releaseFacts(ComicEdition? edition) {
    final releases = edition?.releases ?? const [];
    return [
      for (final release in releases.take(6))
        [
          release.region,
          if (release.publisher != null && release.publisher!.isNotEmpty)
            release.publisher,
          if (release.releaseDate != null) _formatDate(release.releaseDate!),
        ].whereType<String>().join(' | '),
    ];
  }

  List<LibraryInspectorFactData> _providerFacts(
    ComicDetail? detail,
    ComicEdition? edition,
  ) {
    final metadata = edition?.metadataJson;
    final source = edition?.sourceMetadata;
    final releaseIds = edition?.releases
            .map((release) => release.externalIds)
            .whereType<Map<String, dynamic>>()
            .expand((ids) => ids.entries)
            .map((entry) => '${entry.key}: ${entry.value}')
            .toSet()
            .join(', ') ??
        '';
    return [
      for (final link in detail?.providerLinks ?? const <ComicProviderLink>[])
        LibraryInspectorFactData(
          link.provider,
          [
            '${link.entityType}: ${link.providerItemId}',
            if (link.siteUrl != null) link.siteUrl,
          ].whereType<String>().join(' | '),
        ),
      if (metadata?['provider'] != null)
        LibraryInspectorFactData('Provider', metadata!['provider'].toString()),
      if (metadata?['provider_item_id'] != null)
        LibraryInspectorFactData(
          'Provider ID',
          metadata!['provider_item_id'].toString(),
        ),
      if (source?['site_detail_url'] != null)
        LibraryInspectorFactData(
            'Source URL', source!['site_detail_url'].toString()),
      if (source?['api_detail_url'] != null)
        LibraryInspectorFactData(
            'API URL', source!['api_detail_url'].toString()),
      if (releaseIds.isNotEmpty)
        LibraryInspectorFactData('Release IDs', releaseIds),
    ];
  }
}

class _CollectionFields extends StatelessWidget {
  const _CollectionFields({
    required this.enabled,
    required this.condition,
    required this.grade,
    required this.conditions,
    required this.grades,
    required this.onConditionChanged,
    required this.onGradeChanged,
  });

  final bool enabled;
  final String? condition;
  final String? grade;
  final List<String> conditions;
  final List<String> grades;
  final ValueChanged<String?>? onConditionChanged;
  final ValueChanged<String?>? onGradeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: conditions.contains(condition) ? condition : null,
            decoration: const InputDecoration(
              labelText: 'Condition',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final option in conditions)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: enabled ? onConditionChanged : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: grades.contains(grade) ? grade : null,
            decoration: const InputDecoration(
              labelText: 'Grade',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final option in grades)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: enabled ? onGradeChanged : null,
          ),
        ),
      ],
    );
  }
}

class _PersonalDetailsEditor extends ConsumerStatefulWidget {
  const _PersonalDetailsEditor({required this.ownedItem});

  final OwnedItem ownedItem;

  @override
  ConsumerState<_PersonalDetailsEditor> createState() =>
      _PersonalDetailsEditorState();
}

class _PersonalDetailsEditorState
    extends ConsumerState<_PersonalDetailsEditor> {
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _notesController;
  DateTime? _purchaseDate;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _currencyController = TextEditingController();
    _notesController = TextEditingController();
    _syncFromItem(widget.ownedItem);
  }

  @override
  void didUpdateWidget(covariant _PersonalDetailsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownedItem.id != widget.ownedItem.id ||
        oldWidget.ownedItem.updatedAt != widget.ownedItem.updatedAt) {
      _syncFromItem(widget.ownedItem);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _currencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD51C1F21),
        border: Border.all(color: const Color(0x554DBBD5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, size: 17, color: _kClzAccent),
                const SizedBox(width: 7),
                Text(
                  'Personal details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _kClzAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            OutlinedButton.icon(
              onPressed: _pickPurchaseDate,
              icon: const Icon(Icons.event),
              label: Text(
                _purchaseDate == null
                    ? 'Set purchase date'
                    : 'Purchased ${_formatDate(_purchaseDate!)}',
              ),
            ),
            if (_purchaseDate != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _purchaseDate = null),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear purchase date'),
                ),
              ),
            ],
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price paid',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      if (_priceError != null) {
                        setState(() => _priceError = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _currencyController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Personal notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 9),
            if (_priceError != null) ...[
              Text(
                _priceError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 9),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save personal details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncFromItem(OwnedItem item) {
    _purchaseDate = item.purchaseDate;
    _priceController.text = item.pricePaidCents == null
        ? ''
        : (item.pricePaidCents! / 100).toStringAsFixed(2);
    _currencyController.text = item.currency ?? 'USD';
    _notesController.text = item.personalNotes ?? '';
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && mounted) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _save() async {
    final price = _parsePriceCents(_priceController.text);
    if (price == null && _priceController.text.trim().isNotEmpty) {
      setState(() {
        _priceError = 'Enter a valid price, for example 3.99';
      });
      return;
    }
    final currency = _currencyController.text.trim().toUpperCase();
    await ref.read(collectionMutationsProvider).updateItem(
          widget.ownedItem,
          condition: widget.ownedItem.condition,
          grade: widget.ownedItem.grade,
          purchaseDate: _purchaseDate,
          pricePaidCents: price,
          currency: currency.isEmpty ? null : currency,
          personalNotes: _emptyToNull(_notesController.text),
          quantity: widget.ownedItem.quantity,
          storageBox: widget.ownedItem.storageBox,
          indexNumber: widget.ownedItem.indexNumber,
          coverPriceCents: widget.ownedItem.coverPriceCents,
          rawOrSlabbed: widget.ownedItem.rawOrSlabbed,
          gradingCompany: widget.ownedItem.gradingCompany,
          graderNotes: widget.ownedItem.graderNotes,
          signedBy: widget.ownedItem.signedBy,
          keyComic: widget.ownedItem.keyComic,
          keyReason: widget.ownedItem.keyReason,
          rating: widget.ownedItem.rating,
          readStatus: widget.ownedItem.readStatus,
          tags: widget.ownedItem.tags,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal details saved')),
      );
    }
  }

  int? _parsePriceCents(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      return null;
    }
    return (parsed * 100).round();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC172E35),
        border: Border.all(color: const Color(0x664DBBD5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _kClzAccent),
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

class _IssuePill extends StatelessWidget {
  const _IssuePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _kClzYellow,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF151515),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    return LibraryCoverImage(
      title: item.title,
      itemNumber: item.itemNumber,
      imageUrl: item.displayCoverUrl,
    );
  }
}

class _EmptyInspector extends StatelessWidget {
  const _EmptyInspector();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No comic selected'));
  }
}

Set<String> _watchWishlistIds(WidgetRef ref) {
  return ref.watch(wishlistIdsProvider).maybeWhen(
        data: (ids) => ids,
        orElse: () => const <String>{},
      );
}

String _formatOptionalMoney(int? cents, String? currency) {
  if (cents == null) {
    return '';
  }
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  final prefix = currency == null || currency.isEmpty ? '' : '$currency ';
  return '$prefix$sign$whole.$fraction';
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

String? _formatNullableDate(DateTime? value) {
  return value == null ? null : _formatDate(value);
}

extension _BlankStringFallback on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

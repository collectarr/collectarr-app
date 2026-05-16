import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/comics/comic_detail_page.dart';
import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:collectarr_app/features/comics/comics_inspector_formatters.dart';
import 'package:collectarr_app/features/comics/comics_personal_details_editor.dart';
import 'package:collectarr_app/features/comics/comics_rich_metadata_inspector.dart';
import 'package:collectarr_app/features/comics/metadata_correction_dialog.dart';
import 'package:collectarr_app/features/comics/owned_comic_edit_dialog.dart';
import 'package:collectarr_app/features/library/library_item_state.dart';
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
              ComicCollectionFields(
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
                ComicPersonalDetailsEditor(ownedItem: ownedItem),
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
              ComicsRichMetadataInspector(
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
            if (item.releaseDate != null)
              formatComicInspectorDate(item.releaseDate!),
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
                label: formatComicInspectorMoney(
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book, size: 42, color: _kClzAccent),
          const SizedBox(height: 12),
          const Text(
            'No comic selected',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select an item to inspect metadata, cover, and local status.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _kClzTextMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

Set<String> _watchWishlistIds(WidgetRef ref) {
  return ref.watch(wishlistIdsProvider).maybeWhen(
        data: (ids) => ids,
        orElse: () => const <String>{},
      );
}
